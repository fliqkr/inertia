# Controller for the /search route
class SearchController < ApplicationController
  include GoogleHelper
  include UrlHelper
  include WikipediaHelper

  def search
    search_query = params[:query]

    # TODO: Better benchmark timers (clicking on it opens a drawer which displays how long each step took)

    # Start a timer
    start_time = Time.now

    # Results -->

    @results = google_text_search(search_query)

    @widgets = []

    # Wikipedia ->
    wikipedia_result = get_wikipedia_summary(@results)
    @widgets << { type: 'wikipedia', content: wikipedia_result } if !wikipedia_result.nil?

    # ---------->

    # Calculate the elapsed time
    elapsed_time = Time.now - start_time

    # Format the time
    @time_elapsed = "%.2f seconds" % elapsed_time

    render :search
  end
end
