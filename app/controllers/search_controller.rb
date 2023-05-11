# Controller for the /search route
class SearchController < ApplicationController
  include GoogleHelper

  def search
    search_query = params[:query]
    @results = google_text_search(search_query)
    render :search
  end
end
