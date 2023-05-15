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
    # Get the conversion object
    conversion = determine_conversion(query)
    return nil unless conversion

    value = conversion[:value]
    from = conversion[:from]
    to = conversion[:to]

    conversion_type = determine_conversion_type(from, to)
    return nil unless conversion_type

    converter = Converter.new(conversion_type, from, to)

    from_real_name = ConversionDefinition.resolve_alias(conversion_type, from)
    to_real_name = ConversionDefinition.resolve_alias(conversion_type, to)
    from_pretty_name = ConversionDefinition.get_pretty_name(conversion_type, from_real_name)
    to_pretty_name = ConversionDefinition.get_pretty_name(conversion_type, to_real_name)

    { query: "#{value} #{from_pretty_name} in #{to_pretty_name}", result_pretty_name: to_pretty_name, result: converter.convert(value) }
  end

  def determine_conversion(query)
    # Check if the regex matches the query
    regex = /\s?(\d+)\s?(\S+)\s?(to|in)\s?(\S+)/
    match = query.match(regex)
    return nil unless match

    # Get the different values
    value =
      begin
        Float(match[1])
      rescue ArgumentError, TypeError
        nil
      end
    return nil unless value

    from = match[2]
    to = match[4]
    return nil unless from || to

    { value: value, from: from, to: to }
  end

  # Determines the type of a conversion by trying to match the two types to the definitions
  def determine_conversion_type(from, to)
    ConversionDefinition.valid_conversions.keys.detect do |key|
      ConversionDefinition.valid_conversion?(key, from, to)
    end
  end
end
