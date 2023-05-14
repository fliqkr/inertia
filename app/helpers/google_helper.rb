require 'httparty'
require 'nokogiri'

# A helper for Google related searches
module GoogleHelper
  # Some variables from the configuration
  config = Rails.configuration.inertia.google

  TLD = config[:tld]
  USER_AGENT = config[:user_agent]

  def google_text_search(query, page)
    # Encode the query
    query = URI.encode_www_form_component(query).gsub('+', '%20')

    # Send the request to Google
    url = "https://www.google.#{TLD}/search?q=#{query}&start=#{page * 10}"
    res = HTTParty.get(url, headers: { 'User-Agent' => USER_AGENT })
    html = res.body

    # Get the DOM
    dom = Nokogiri::HTML(html)
    # We store our final results here
    results = []

    # Select result boxes
    # You can view the current DOM layout of Google by just searching
    # for something and exploring it with devtools.
    # NOTE: Class `.liYKde` contains a href for '#' which breaks stuff.
    dom.css('div.g:not(.liYKde)').each do |item|
      # Result Properties -->

      # Select the result title, description and link
      title_elem = item.css('h3').first
      link_elem = item.css('a').first
      description_elem = item.css('div.VwiC3b').first

      # Get the content
      title = title_elem.text.strip if title_elem
      link = link_elem['href'].sub(/^\/url\?q=/, '').split('&').first if link_elem
      description = description_elem.text.strip if description_elem

      # Result Widgets -->
      sublinks = get_sublinks(item)
      rich_content_object = get_rich_content_object(item)

      # Optionally get a favicon
      favicon_elem = item.css('img.XNo5Ab').first
      favicon = favicon_elem['src'] if favicon_elem

      # Add it to our results
      results << {
        title: title,
        link: link,
        description: description,
        favicon: favicon,
        sublinks: sublinks,
        rich_content_object: rich_content_object
      }
    end

    # Count the amount of pages
    pages = dom.css('.AaVjTc .fl').length + 1 # NOTE: We add one more because of the current one we are on.

    # Return the results
    { results: results, pages: pages }
  end

  # Returns sublinks that exist within a page
  def get_sublinks(item)
    # Get the parent table
    parent = item.css('table.jmjoTe').first
    # Table elements
    links = item.css('tr.mslg')

    sublinks = []

    # Loop over all the table elements
    links.each do |link|
      # Select the sublink title, description and link
      title_elem = link.css('h3').first
      link_elem = link.css('a').first
      description_elem = link.css('div.zz3gNc').first

      # Get the content
      title = title_elem.text.strip if title_elem
      link = link_elem['href'].sub(/^\/url\?q=/, '').split('&').first if link_elem
      description = description_elem.text.strip if description_elem

      sublinks << { title: title, link: link, description: description }
    end

    # Return the sublinks
    sublinks
  end

  # Returns key-value based rich content, e.g. the amount of edits on Wikipedia
  def get_rich_content_object(item)
    # Get the parent div
    parent = item.css('div.Z26q7c').first
    # Object fields
    fields = item.css('div.wFMWsc')

    rich_content = []

    fields.each do |field|
      key_elem = field.css('span.YrbPuc').first
      value_elem = field.css('span.wHYlTd').first

      # Check what type the value is (text/link)
      value_link_elem = value_elem.css('a').first
      value_type =
        if !value_link_elem.nil?
          :link
        else
          :text
        end

      value_content =
        if value_type == :link
          label = value_link_elem.text.strip if value_link_elem
          link = value_link_elem['href'].sub(/^\/url\?q=/, '').split('&').first if value_link_elem
          "#{label}|#{link}"
        elsif value_type == :text
          value_elem.text.strip
        end

      # Get the content
      key = key_elem.text.strip if key_elem
      value = { type: value_type, content: value_content }

      rich_content << { key: key, value: value }
    end

    rich_content
  end
end
