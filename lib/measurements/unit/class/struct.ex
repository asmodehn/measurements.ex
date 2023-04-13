defmodule Class.Struct do
  # TODO : typed_struct would be useful here...

  # generic type to be refined in module importing class
  @type t() :: any()

  # callback to implement in the module defining the struct (internal data)
  @callback generator() :: t()

  defmacro definternal(fields) do
    quote do
      # usual defstruct
      defstruct unquote(fields)

      # internal type
      @type t :: %__MODULE__{unquote_splicing(fields)}
    end
  end

  # TODO : maybe a different module ??
  defmacro defrepr(_format) do
    # TODO format string representing the struct (element of the class)
    # TODO : property should also be faithful in the representation (naturality of hte functor)
    quote do
      :not_yet_implemented
    end
  end
end
