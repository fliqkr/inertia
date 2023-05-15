# Definition class for conversions
class ConversionDefinition
  def self.valid_conversions
    {
      weight: {
        'lbs' => {
          aliases: %w([pounds] [lb]),
          conversions: {
            'kg' => ->(value) { value * 0.453592 }
          }
        },
        'kg' => {
          aliases: %w([kilogram] [kilograms] [kgs]),
          conversions: {
            'lbs' => ->(value) { value * 2.20462 }
          }
        }
      }
    }
  end

  def self.valid_conversion?(type, from, to)
    valid_conversions[type]&.[](from)&.key?(to)
  end

  def self.get_conversion(type, from, to)
    valid_conversions[type][from][:conversions][to]
  end

  def self.get_aliases(type, unit)
    valid_conversions[type][unit][:aliases]
  end
end
