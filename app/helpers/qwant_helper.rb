# A helper for Qwant related searches
module QwantHelper
  # Some variables from the configuration
  config = Rails.configuration.inertia.qwant

  USER_AGENT = config[:user_agent]

  def qwant_image_search(query)
    # Encode the query
    query = URI.encode_www_form_component(query).gsub('+', '%20')

    # Send the request to Qwant
    url = "https://lite.qwant.com/?q=#{query}&t=images"
    res = HTTParty.get(url, headers: { 'User-Agent' => USER_AGENT })
    html = res.body

    # Get the DOM
    dom = Nokogiri::HTML(html)
    # We store our final results here
    results = []

    dom.css('.images-container a[href]').each do |item|
      # Get the full resolution image link
      href = item['href']
      decoded_link = Base64.decode64(href.match(/\/redirect\/(.*)\/(.*)\?/)[2])
      image_link = URI.decode_www_form_component(decoded_link)

      # Get the thumbnail
      image_elem = item.css('img').first
      thumbnail = "/image/?url=#{URI.encode_www_form_component(Base64.encode64(image_elem['src']))}"
      alt = image_elem['alt']

      results << {
        image_link: image_link,
        thumbnail: thumbnail,
        alt: alt
      }
    end

    # Return the results
    results
  end
end
