defprotocol Measurements.Measurement do
  def value(m)
  def error(m)
  def unit(m)

  def convert(m, unit)
end
