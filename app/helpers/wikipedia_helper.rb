require 'httparty'
require 'base64'

# A helper for fetching info from Wikipedia
module WikipediaHelper
  def get_wikipedia_summary(search_results)
    config = Rails.configuration.inertia.wikipedia

    wikipedia_language = config[:language]
    user_agent = config[:user_agent]

    # Filter out all elements
    wikipedia_results =
      search_results.select do |result|
        result[:link].include?("#{wikipedia_language}.wikipedia.org/wiki")
      end

    # Only filter out the first element
    wikipedia_result = wikipedia_results.first[:link]
    return nil if wikipedia_result.nil?

    # We should redirect a couple of titles to better definitions, such as 'Main_Page'
    redirect = {
      'Main_Page' => 'Wikipedia'
    }

    # Get the page title
    url_title = wikipedia_result.split('/').last
    wikipedia_title = redirect[url_title] || url_title

    # Add the new wikipedia_title back to the link
    wikipedia_result = "https://#{wikipedia_language}.wikipedia.org/wiki/#{wikipedia_title}"

    # Construct the URL
    url = "https://#{wikipedia_language}.wikipedia.org/w/api.php?action=query&prop=extracts|pageimages&format=json&exintro=&explaintext=&exchars=500&piprop=thumbnail&pithumbsize=300&titles=#{wikipedia_title}"

    # Request the URL
    res = HTTParty.get(url, headers: { 'User-Agent' => user_agent })
    summary_page = res.parsed_response['query']['pages'].values.first
    summary_title = summary_page['title']
    summary_text = summary_page['extract'].gsub('...', '')

    # Modify the summary text to cut off the current sentence that wasn't finished yet.
    summary_text = summary_text.slice(0, summary_text.rindex('.') + 1) if summary_text && summary_text.include?('.')

    # Strip out the IPA listening feature
    summary_text = summary_text.gsub(/\((.*?)(\s?)\(listen\)\)/, '') if summary_text

    # Fetch the thumbnail image
    summary_thumbnail = summary_page['thumbnail']
    summary_image_link = summary_thumbnail['source']
    summary_image_data =
      if summary_image_link
        Base64.encode64(
          HTTParty.get(summary_image_link, headers: { 'User-Agent' => user_agent }).body
        )
      end
    summary_image = { width: summary_thumbnail['width'], height: summary_thumbnail['height'], data: summary_image_data }

    summary = { title: summary_title, text: summary_text, thumbnail: summary_image, article: wikipedia_result }

    # Return the summary
    summary.present? ? summary : nil
  rescue
    # Return nil if something failed
    nil
  end
end
