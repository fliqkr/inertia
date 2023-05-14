require 'httparty'

# A small controller to proxy images
class ImageController < ApplicationController
  # Some variables from the configuration
  config = Rails.configuration.inertia
  USER_AGENT = config[:user_agent]

  def proxy
    url = params[:url]
    url = Base64.decode64(URI.decode_www_form_component(url))

    # Check if the URL is valid and if it supplies an image
    if !valid_url?(url)
      render plain: 'Invalid URL', status: :bad_request
      return
    end

    res = HTTParty.get(url, headers: { 'User-Agent' => USER_AGENT })
    content_type = res.headers['content-type']

    if res.code != 200
      render plain: 'Error Fetching Image'
      return
    end

    unless image_url?(content_type)
      render plain: 'Invalid Image', status: :bad_request
      return
    end

    send_data res.body, type: content_type, disposition: 'inline'
  end

  private

  def valid_url?(url)
    url =~ URI::DEFAULT_PARSER.make_regexp
  end

  def image_url?(content_type)
    content_type.present? && content_type.start_with?('image/')
  end
end
