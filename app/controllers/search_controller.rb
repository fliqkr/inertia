# Controller for the /search route
class SearchController < ApplicationController
  include GoogleHelper
  include UrlHelper
  include WikipediaHelper

  def search
    search_query = params[:query]

    begin
      search_type = Integer(params[:type]).abs
    rescue ArgumentError, TypeError
      search_type = 0
    end

    # TODO: Better benchmark timers (clicking on it opens a drawer which displays how long each step took)
    # Start a timer
    start_time = Time.now

    # Results -->
    case search_type
    when 0 # Text search
      @results = google_text_search(search_query)
      @widgets = []

      # Wikipedia ->
      wikipedia_result = get_wikipedia_summary(@results)
      @widgets << { type: 'wikipedia', content: wikipedia_result } if !wikipedia_result.nil?

      rendered_page = :search_text
    when 1 # Image search
      @results = google_image_search(search_query)

      rendered_page = :search_image
    end
    # ---------->

    # Calculate the elapsed time
    elapsed_time = Time.now - start_time

    # Format the time
    @time_elapsed = "%.2f seconds" % elapsed_time

    render rendered_page || :search_text
  end
end
