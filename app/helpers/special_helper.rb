# A helper for special searches
module SpecialHelper
  def get_network_information(request, query)
    search_queries = ['what is my ip', 'what is my user agent']

    ip =
      if Rails.configuration.inertia.host[:proxy] == true
        request.headers['X-Real-IP'] || nil
      else
        request.remote_ip
      end

    search_queries.any? { |el| query.include?(el) } ? { ip: ip, user_agent: request.user_agent } : nil
  end

  def get_conversion(query)
    conversion = determine_conversion(query)
    puts 'a', conversion
    return nil unless conversion

    type, from, to = conversion
    converter = Converter.new(type, from, to)

    match = query.match(/(\d+)\s+#{Regexp.escape(from)}\s+to\s+#{Regexp.escape(to)}/)
    puts 'b', match
    return nil unless match

    value = match[1].to_i

    result = converter.convert(value)

    "#{value} #{from} is equal to #{result} #{to}"
  end

  def determine_conversion(query)
    conversions = ConversionDefinition.valid_conversions

    conversions.each do |type, units|
      units.each do |unit, definition|
        aliases = definition[:aliases]

        if aliases.any? { |alias_str| query.include?(alias_str) }
          from = unit
          to = aliases.find { |alias_str| query.include?(alias_str) }
          return [type, from, to]
        end
      end
    end

    nil
  end
end
