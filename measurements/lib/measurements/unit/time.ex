defmodule Measurements.Unit.Time do

  alias Measurements.Dimension
  alias Measurements.Scale

  # The one place to manage the time unit atoms, for compatibility with Elixir.System
  @second :second
  @millisecond :millisecond
  @microsecond :microsecond
  @nanosecond :nanosecond

  # invert units
  @hertz :hertz
  @kilohertz :kilohertz
  @megahertz :megahertz
  @gigahertz :gigahertz


  @type t :: atom | non_neg_integer


  @behaviour Dimensionable
  @impl Dimensionable
  def dimension(@second), do: Dimension.new() |> Dimension.with_time(1)
  def dimension(@millisecond), do: Dimension.new() |> Dimension.with_time(1)
  def dimension(@microsecond), do: Dimension.new() |> Dimension.with_time(1)
  def dimension(@nanosecond), do: Dimension.new() |> Dimension.with_time(1)
  def dimension(ps) when is_integer(ps) and ps > 0, do: Dimension.new() |> Dimension.with_time(1)

  def dimension(@hertz), do: Dimension.new() |> Dimension.with_time(-1)
  def dimension(@kilohertz), do: Dimension.new() |> Dimension.with_time(-1)
  def dimension(@megahertz), do: Dimension.new() |> Dimension.with_time(-1)
  def dimension(@gigahertz), do: Dimension.new() |> Dimension.with_time(-1)

  def dimension(other), do: raise ArgumentError, message: argument_error_message(other)


  @behaviour Scalable
  @impl Scalable
  def scale(@second), do: Scale.new(0)
  def scale(@millisecond), do: Scale.new(-3)
  def scale(@microsecond), do: Scale.new(-6)
  def scale(@nanosecond), do: Scale.new(-9) 
  def scale(ps) when is_integer(ps) and ps > 0, do: Scale.new(0)

  def scale(@hertz), do: Scale.new(0) 
  def scale(@kilohertz), do: Scale.new(3)
  def scale(@megahertz), do: Scale.new(6)
  def scale(@gigahertz), do: Scale.new(9)

  def scale(other), do: raise ArgumentError, message: argument_error_message(other)

  # @doc """
  #   Normalizes time_unit, just like internal Elixir's System.normalize

  # The main difference is that it does **not** accept deprecated units, nor :native, as it is a local-specific unit,
  # and is not a unit that can be shared or propagated around.
  # """
  # def new(@second), do: @second
  # def new(@millisecond), do: @millisecond
  # def new(@microsecond), do: @microsecond
  # def new(@nanosecond), do: @nanosecond

  # def new(@hertz), do: 1
  # def new(@kilohertz), do: 1_000
  # def new(@megahertz), do: 1_000_000
  # def new(@gigahertz), do: 1_000_000_000

  # def new(unit) when is_integer(unit) and unit > 0, do: unit

  # def new(other) do
  #   raise ArgumentError, argument_error_message(other)
          
  # end



  @spec new(Scale.t, Dimension.t) :: {:ok, atom} | {:error, fun, atom}
  def new(%Scale{} = s, %Dimension{time: 1, length: 0, mass: 0, current: 0, temperature: 0, substance: 0, lintensity: 0}) do
    
    case s.ten_power do
      0 -> {:ok, @second}
      -3 -> {:ok, @millisecond}
      -6 -> {:ok, @microsecond}
      -9 -> {:ok, @nanosecond}
      scale -> {:error, fn v -> v * 10 ** scale end, @second}
    end

  end


  def new(%Scale{} = s, %Dimension{time: -1, length: 0, mass: 0, current: 0, temperature: 0, substance: 0, lintensity: 0}) do
    
    case s.ten_power do
      0 -> {:ok, @hertz}
      3 -> {:ok, @kilohertz}
      6 -> {:ok, @megahertz}
      9 -> {:ok, @gigahertz}
      scale -> {:error, fn v -> v * 10 ** scale end, @hertz}
    end

  end



  # @doc """
  # 	Returns the ratio u1 / u2 in the power of tens, in order to manage comparaison and conversion without going into floating points.
  # """
  # def power_ratio(@second, @second), do: 0
  # def power_ratio(@millisecond, @millisecond), do: 0
  # def power_ratio(@microsecond, @microsecond), do: 0
  # def power_ratio(@nanosecond, @nanosecond), do: 0

  # def power_ratio(@hertz, @hertz), do: 0
  # def power_ratio(@kilohertz, @kilohertz), do: 0
  # def power_ratio(@megahertz, @megahertz), do: 0
  # def power_ratio(@gigahertz, @gigahertz), do: 0

  # def power_ratio(@second, @millisecond), do: 3
  # def power_ratio(@millisecond, @microsecond), do: 3
  # def power_ratio(@microsecond, @nanosecond), do: 3
  # def power_ratio(@second, @microsecond), do: 6
  # def power_ratio(@second, @nanosecond), do: 9
  # def power_ratio(@millisecond, @nanosecond), do: 6

  # def power_ratio(@kilohertz, @hertz), do: 3
  # def power_ratio(@megahertz, @kilohertz), do: 3
  # def power_ratio(@gigahertz, @megahertz), do: 3
  # def power_ratio(@megahertz, @hertz), do: 6
  # def power_ratio(@gigahertz, @hertz), do: 9
  # def power_ratio(@gigahertz, @kilohertz), do: 6

  # # CAREFUL to not mix frequency and period measurements, as result unit would not be what is expected from a ratio.
  # def power_ratio(u1, u2) when is_atom(u1) and is_atom(u2) do
  #   raise ArgumentError, message: "incompatible arguments #{u1} and #{u2}"
  # end

  # @doc """
  # 	Returns the ratio u1 / u2.
  # 	This can help determining the most precise unit, as well as converting from one to another
  # """
  # def ratio(@second, @second), do: 1
  # def ratio(@millisecond, @millisecond), do: 1
  # def ratio(@microsecond, @microsecond), do: 1
  # def ratio(@nanosecond, @nanosecond), do: 1

  # def ratio(@hertz, @hertz), do: 1
  # def ratio(@kilohertz, @kilohertz), do: 1
  # def ratio(@megahertz, @megahertz), do: 1
  # def ratio(@gigahertz, @gigahertz), do: 1

  # def ratio(@second, @millisecond), do: 1_000
  # def ratio(@millisecond, @microsecond), do: 1_000
  # def ratio(@microsecond, @nanosecond), do: 1_000
  # def ratio(@second, @microsecond), do: 1_000_000
  # def ratio(@second, @nanosecond), do: 1_000_000_000
  # def ratio(@millisecond, @nanosecond), do: 1_000_000

  # def ratio(@kilohertz, @hertz), do: 1_000
  # def ratio(@megahertz, @kilohertz), do: 1_000
  # def ratio(@gigahertz, @megahertz), do: 1_000
  # def ratio(@megahertz, @hertz), do: 1_000_000
  # def ratio(@gigahertz, @hertz), do: 1_000_000_000
  # def ratio(@gigahertz, @kilohertz), do: 1_000_000

  # # CAREFUL to not mix frequency and period measurements in any other way,
  # # as result unit would not be what is expected from a ratio.
  # def ratio(u1, u2) when is_atom(u1) and is_atom(u2) do
  #   raise ArgumentError, message: "incompatible arguments #{u1} and #{u2}"
  # end

  # # managing **special cases** where integer means "per second" as per Elixir.System semantics
  # def ratio(@second, u2) when is_integer(u2) and u2 > 0, do: u2
  # # with power of ten
  # def ratio(@millisecond, u2) when is_integer(u2) and u2 > 0, do: u2 * 10 ** -3
  # def ratio(@microsecond, u2) when is_integer(u2) and u2 > 0, do: u2 * 10 ** -6
  # def ratio(@nanosecond, u2) when is_integer(u2) and u2 > 0, do: u2 * 10 ** -9

  # # and the inverse (on inverted argument order)
  # def ratio(u1, @hertz) when is_integer(u1) and u1 > 0, do: u1
  # # with power of ten
  # def ratio(u1, @kilohertz) when is_integer(u1) and u1 > 0, do: u1 * 10 ** -3
  # def ratio(u1, @megahertz) when is_integer(u1) and u1 > 0, do: u1 * 10 ** -6
  # def ratio(u1, @gigahertz) when is_integer(u1) and u1 > 0, do: u1 * 10 ** -9
  # # TODO : delay power operations until later, to involve float only if absolutely necessary 

  # # BEWARE: tricky cases... may involve floats... user code should avoid it if possible...

  # def ratio(u1, @second) when is_integer(u1) and u1 > 0, do: 1 / u1
  # def ratio(u1, @millisecond) when is_integer(u1) and u1 > 0, do: 1 / u1 * 10 ** 3
  # def ratio(u1, @microsecond) when is_integer(u1) and u1 > 0, do: 1 / u1 * 10 ** 6
  # def ratio(u1, @nanosecond) when is_integer(u1) and u1 > 0, do: 1 / u1 * 10 ** 9

  # def ratio(@hertz, u2) when is_integer(u2) and u2 > 0, do: 1 / u2
  # def ratio(@kilohertz, u2) when is_integer(u2) and u2 > 0, do: 1 / u2 * 10 ** 3
  # def ratio(@megahertz, u2) when is_integer(u2) and u2 > 0, do: 1 / u2 * 10 ** 6
  # def ratio(@gigahertz, u2) when is_integer(u2) and u2 > 0, do: 1 / u2 * 10 ** 9



  defp argument_error_message(other), do: "unsupported time unit. Expected #{@second}, #{@millisecond}, " <>
            "#{@microsecond}, #{@nanosecond}, #{@hertz}, #{@kilohertz}, " <>
            "#{@megahertz}, #{@gigahertz}, or any positive integer. " <>
            "Got #{inspect(other)}"

end
