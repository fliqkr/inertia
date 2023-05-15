# A class for creating converters
class Converter
  attr_reader :type, :from, :to

  def initialize(type, from, to)
    @type = type
    @from = from
    @to = to
  end

  def convert(value)
    conversion = ConversionDefinition.get_conversion(type, @from, @to)
    return nil unless conversion

    conversion.call(value)
  end
end
