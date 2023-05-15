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
end
