# A helper for URL based actions
module UrlHelper
  # Display URL's in a pretty way
  def format_url(url)
    separator = ' › '

    # Parse the URL
    uri = URI.parse(url)

    # Transform it using the separator
    host = uri.host.chomp('/')
    path = uri.path.split('/').map { |part| URI.decode_www_form_component(part) }.join(separator)

    # Return the formatted URL
    "#{uri.scheme}://#{host}#{path}"
  end
end
