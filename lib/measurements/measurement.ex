defprotocol Measurements.Measurement do
  def value(m)
  def error(m)
  def unit(m)

  def convert(m, unit)

  # TODO : this should eventually become a type class, so that we check properties on unit conversion
end
