defmodule Class.Property do
  @moduledoc "A *very* simple prop checker"

  defmodule UndefinedError do
    @moduledoc ~S"""
    Warning if a type class is missing properties.
    Properties are required for all type classes.
    """

    @type t :: %TypeClass.Property.UndefinedError{
            type_class: module(),
            message: String.t()
          }

    defexception message: "Property not defined for type", type_class: nil

    @doc ~S"""
    Convenience constructor

    ## Examples

        iex> TypeClass.Property.UndefinedError.new(CoolClass)
        %TypeClass.Property.UndefinedError{
          type_class: CoolClass,
          message: ~S"
          CoolClass has not defined any properties, but they are required.

          See `TypeClass.properties/1` for more
          "
        }

    """
    @spec new(module()) :: t()
    def new(class) do
      %TypeClass.Property.UndefinedError{
        type_class: class,
        message: """
        #{class} has not defined any properties, but they are required.

        See `TypeClass.properties/1` for more
        """
      }
    end
  end

  @doc "Ensure that the type class has defined properties"
  @spec ensure!() :: no_return()
  defmacro ensure! do
    quote do
      case Code.ensure_loaded(__MODULE__.Property) do
        {:module, _prop_submodule} ->
          nil

        {:error, :nofile} ->
          raise UndefinedError.new(__MODULE__)
      end
    end
  end

  # TODO : custom generator => oidification...
  # => with streamdata / exunitproperties

  # @doc "Run all properties for the type class"
  # @spec run!(module(), module(), atom(), non_neg_integer()) :: no_return()
  # def run!(datatype, class, prop_name, times \\ 100) do
  #   property_module = Module.concat(class, Property)
  #   custom_generator = Module.concat([class, "Proto", datatype]).__custom_generator__()

  #   data_generator =
  #     if custom_generator do
  #       custom_generator
  #     else
  #       Module.concat(TypeClass.Property.Generator, datatype).generate(nil)
  #     end

  #   fn ->
  #     unless apply(property_module, prop_name, [data_generator]) do
  #       raise TypeClass.Property.FailedCheckError.new(datatype, class, prop_name)
  #     end
  #   end
  #   |> Stream.repeatedly()
  #   |> Enum.take(times)
  # end
end
