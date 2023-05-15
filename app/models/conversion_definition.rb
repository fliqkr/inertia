# Definition class for conversions
class ConversionDefinition
  def self.valid_conversions
    {
      weight: {
        'lbs' => {
          pretty_name: 'pounds',
          aliases: %w[pound pounds lb],
          conversions: {
            'kg' => ->(value) { value * 0.453592 }
          }
        },
        'kg' => {
          pretty_name: 'kilograms',
          aliases: %w[kilogram kilograms kgs],
          conversions: {
            'lbs' => ->(value) { value * 2.20462 }
          }
        }
      }
    }
  end

  def self.valid_conversion?(type, from, to)
    from = resolve_alias(type, from)
    to = resolve_alias(type, to)
    valid_conversions[type]&.dig(from, :conversions)&.key?(to)
  end

  def self.get_conversion(type, from, to)
    from = resolve_alias(type, from)
    to = resolve_alias(type, to)
    valid_conversions[type][from][:conversions][to]
  end

  def self.get_aliases(type, unit)
    valid_conversions[type][unit][:aliases]
  end

  def self.get_pretty_name(type, unit)
    valid_conversions[type][unit][:pretty_name]
  end

  def self.resolve_alias(type, str)
    valid_conversions[type].each do |key, value|
      (key == str || value[:aliases].include?(str)) && (return key)
    end
  end
end
