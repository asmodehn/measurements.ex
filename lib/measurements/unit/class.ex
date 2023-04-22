defmodule Class do
  # defmacro __using__(_) do

  #   quote do

  #   import Class, only: [defclass: 2, definst: 2, classtest: 2]

  #     @impl Class
  #     def generate(), do: :ok

  #     defoverridable [generate: 0]
  #   end
  # end

  # end

  defmacro defclass(class_name, do: body) do
    quote do
      defmodule unquote(class_name) do
        # import TypeClass.Property.Generator, only: [generate: 1]
        # import TypeClass.Property.Generator.Custom

        require Class.Property

        use Class.Dependency

        # Module.register_attribute(__MODULE__, :force_type_class, [])
        # @force_type_class false

        # Module.register_attribute(__MODULE__, :class_methods, [])
        # @class_methods false

        unquote(body)

        # @doc false
        # def __force_type_class__, do: @force_type_class

        Class.run_where!()
        Class.Dependency.run()
        Class.Property.ensure!()
      end
    end
  end

  defmacro where(do: fun_specs) do
    Module.put_attribute(__CALLER__.module, :class_methods, fun_specs)
  end

  defmacro run_where! do
    class = __CALLER__.module
    fun_specs = Module.get_attribute(class, :class_methods)
    proto = (Module.split(class) ++ ["Proto"]) |> Enum.map(&String.to_atom/1)

    fun_stubs =
      case fun_specs do
        nil -> []
        {:__block__, _ctx, funs} -> funs
        fun = {:def, _ctx, _inner} -> [fun]
      end

    delegates =
      fun_stubs
      |> List.wrap()
      |> Enum.filter(fn
        # remove fallback_to_any in module
        {:@, _ctx, [{:fallback_to_any, _, _}]} -> false
        _ -> true
      end)
      |> Enum.map(fn
        {:def, ctx, fun} ->
          {
            :defdelegate,
            ctx,
            fun ++ [[to: {:__aliases__, [alias: false], proto}]]
          }

        ast ->
          ast
      end)

    quote do
      defprotocol Proto do
        @moduledoc ~s"""
        Protocol for the `#{unquote(class)}` type class

        For this type class's API, please refer to `#{unquote(class)}`
        """

        # import TypeClass.Property.Generator.Custom

        Macro.escape(unquote(fun_specs), unquote: true)
      end

      unquote(delegates)
    end
  end

  defmacro properties(do: prop_tests) do
    class = __CALLER__.module
    proto = Module.concat(Module.split(class) ++ [Proto])

    leaf =
      class
      |> Module.split()
      |> List.last()
      |> List.wrap()
      |> Module.concat()

    quote do
      defmodule Property do
        @moduledoc false

        alias unquote(class)
        alias unquote(proto), as: unquote(leaf)

        unquote(prop_tests)
      end
    end
  end

  defmacro definst(class, opts, do: body) do
    # __MODULE__ == TypeClass
    [for: datatype] = opts

    quote do
      instance = Module.concat([unquote(class), Proto, unquote(datatype)])

      # __MODULE__ == datatype
      datatype_module = unquote(datatype)

      defimpl unquote(class).Proto, for: datatype_module do
        # import TypeClass.Property.Generator.Custom

        # __MODULE__ == class.Proto.datatype
        # Module.register_attribute(__MODULE__, :force_type_instance, [])
        # @force_type_instance false

        # Module.register_attribute(__MODULE__, :datatype, [])
        # @datatype datatype_module

        # @doc false
        # def __custom_generator__, do: false
        # defoverridable __custom_generator__: 0

        unquote(body)

        # @doc false
        # def __force_type_instance__, do: @force_type_instance
      end

      # cond do
      #   unquote(class).__force_type_class__() ->
      #     IO.warn("""
      #     The type class #{unquote(class)} has been forced to bypass \
      #     all property checks for all data types. This is very rarely valid, \
      #     as all type classes should have properties associted with them.

      #     For more, please see the TypeClass README:
      #     https://github.com/expede/type_class/blob/master/README.md
      #     """)

      #   instance.__force_type_instance__() ->
      #     IO.warn("""
      #     The data type #{unquote(datatype)} has been forced to skip property \
      #     validation for the type class #{unquote(class)}

      #     This is sometimes valid, since TypeClass's property checker \
      #     may not be able to accurately validate all data types correctly for \
      #     all possible cases. Forcing a type instance in this way is like telling \
      #     the checker "trust me this is correct", and should only be used as \
      #     a last resort.

      #     For more, please see the TypeClass README:
      #     https://github.com/expede/type_class/blob/master/README.md
      #     """)

      #   true ->
      #     unquote(datatype) |> conforms(to: unquote(class))
      # end

      # TODO: run test during compilation as well ???
    end
  end

  defmacro classtest(class, opts \\ []) do
    # __MODULE__ == TypeClass
    [for: datatype] = opts

    caller = __CALLER__

    require =
      if is_atom(Macro.expand(class, caller)) do
        quote do
          require unquote(class)
        end
      end

    tests =
      quote bind_quoted: [
              class: class,
              # opts: opts,
              datatype: datatype,
              env_line: caller.line,
              env_file: caller.file
            ] do
        property = Module.concat([class, Property])

        for {prop_name, one} <-
              property.__info__(:functions)
              |> Enum.filter(fn
                {n, a} -> not String.starts_with?(Atom.to_string(n), "__")
              end)  # |> IO.inspect()
          do
          t = ExUnit.Case.register_test(__MODULE__, env_file, env_line, :classtest, prop_name, [])

          def unquote(t)(_) do
            # calling prop_name test from property module, with datatype in context
            apply(unquote(property), unquote(prop_name), [%{module: unquote(datatype)}])
          end
        end
      end

    [require, tests]
  end
end
