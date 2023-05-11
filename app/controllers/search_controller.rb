# Controller for the /search route
class SearchController < ApplicationController
  include GoogleHelper

  def search
    search_query = params[:query]

    # Start a timer
    start_time = Time.now

    @results = google_text_search(search_query)

    # Calculate the elapsed time
    elapsed_time = Time.now - start_time

    # Format the time
    @time_elapsed = "%.2f seconds" % elapsed_time

    render :search
  end
end
