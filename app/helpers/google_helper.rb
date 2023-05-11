require 'httparty'
require 'nokogiri'

# A helper for Google-related searches
module GoogleHelper
  def google_text_search(query)
    # Some variables from the configuration
    config = Rails.configuration.inertia.google

    tld = config[:tld]
    user_agent = config[:user_agent]

    # Send the request to Google
    url = "https://www.google.#{tld}/search?q=#{URI.encode_www_form_component(query)}"
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
      title = item.css('h3').text
      link = item.css('a').first['href']
      description = item.css('div.VwiC3b').text

      # Add it to our results
      results << { title: title, link: link, description: description }
    end

    # Return the results
    results
  end
end
