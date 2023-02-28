defmodule Measurements.Scale do
  defstruct magnitude: 0,
            coefficient: 0

  @typedoc "Scale Type"
  @type t :: %__MODULE__{
          magnitude: integer,
          coefficient: integer
        }

  def new(magnitude \\ 0, coefficient \\ 1) do
    %__MODULE__{
      magnitude: magnitude,
      coefficient: coefficient
    }
  end

  def prod(%__MODULE__{} = s1, %__MODULE__{} = s2) do
    %__MODULE__{
      magnitude: s1.magnitude + s2.magnitude,
      coefficient: s1.coefficient * s2.coefficient
    }
  end

  def ratio(%__MODULE__{} = s1, %__MODULE__{coefficient: 1} = s2) do
    # special case for coefficient 1 to not end up with a float if we can avoid it
    %__MODULE__{
      magnitude: s1.magnitude - s2.magnitude,
      coefficient: s1.coefficient
    }
  end

  def ratio(%__MODULE__{} = s1, %__MODULE__{} = s2) do
    %__MODULE__{
      magnitude: s1.magnitude - s2.magnitude,
      coefficient: s1.coefficient / s2.coefficient
    }
    |> IO.inspect()
  end

  def convert(%__MODULE__{} = scale) do
    fn v -> v * to_value(scale) end
  end

  def from_value(value, scale \\ %__MODULE__{})
  def from_value(0, %__MODULE__{} = scale), do: scale

  def from_value(value, %__MODULE__{} = scale) when is_integer(value) do
    next_coefficient = rem(value, 10)

    if next_coefficient != 0 do
      # return immediately if remainder is not zero
      %{scale | coefficient: value + scale.coefficient}
    else
      from_value(
        div(value, 10),
        new(
          scale.magnitude + 1,
          next_coefficient * 10 ** scale.magnitude + scale.coefficient
        )
      )
    end
  end

  @spec to_value(t) :: integer
  def to_value(%__MODULE__{} = scale) do
    scale.coefficient * 10 ** scale.magnitude
  end
end
