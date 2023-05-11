require 'httparty'
require 'nokogiri'

# A helper for Google-related searches
module GoogleHelper
  def google_text_search(query)
    # Encode the query
    query = URI.encode_www_form_component(query).gsub('+', '%20')

    # Some variables from the configuration
    config = Rails.configuration.inertia.google

    tld = config[:tld]
    user_agent = config[:user_agent]

    # Send the request to Google
    url = "https://www.google.#{tld}/search?q=#{query}"
    res = HTTParty.get(url, headers: { 'User-Agent' => user_agent })
    html = res.body

    # Get the DOM
    dom = Nokogiri::HTML(html)
    # We store our final results here
    results = []

    # Select result boxes
    # You can view the current DOM layout of Google by just searching
    # for something and exploring it with devtools.
    dom.css('div.g').each do |item|
      # Select the result title, description and link
      title_elem = item.css('h3').first
      link_elem = item.css('a').first
      description_elem = item.css('div.VwiC3b').first

      title = title_elem.text.strip if title_elem
      link = link_elem['href'].sub(/^\/url\?q=/, '').split('&').first if link_elem
      description = description_elem.text.strip if description_elem

      # Add it to our results
      results << { title: title, link: link, description: description }
    end

    # Return the results
    results
  end
end
