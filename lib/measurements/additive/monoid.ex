import TypeClass

defclass Measurements.Additive.Monoid do
  @moduledoc ~S"""
  """

  extend(Measurements.Additive.Semigroup, alias: true)

  @type t :: any()

  where do
    @doc ~S"""
    """
    def init(sample)
  end

  defalias(zero(sample), as: :init)

  @doc """
  Check if a value is the initial element of that type.
  """
  @spec init?(Measurements.Additive.Monoid.t()) :: boolean
  def init?(monoid), do: init(monoid) == monoid

  properties do
    def left_identity(data) do
      a = generate(data)

      if is_function(a) do
        equal?(
          Semigroup.sum(Measurements.Additive.Monoid.init(a), a).("foo"),
          a.("foo")
        )
      else
        equal?(Semigroup.sum(Measurements.Additive.Monoid.init(a), a), a)
      end
    end

    def right_identity(data) do
      a = generate(data)

      if is_function(a) do
        equal?(
          Semigroup.sum(a, Measurements.Additive.Monoid.init(a)).("foo"),
          a.("foo")
        )
      else
        equal?(Semigroup.sum(a, Measurements.Additive.Monoid.init(a)), a)
      end
    end
  end
end

definst Measurements.Additive.Monoid, for: Integer do
  def init(_i), do: 0
end

definst Measurements.Additive.Monoid, for: Float do
  def init(_f), do: 0.0
end
