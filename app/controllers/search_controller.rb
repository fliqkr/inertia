# Controller for the /search route
class SearchController < ApplicationController
  include GoogleHelper
  include QwantHelper
  include UrlHelper
  include WikipediaHelper

  def search
    @search_query = params[:query]

    begin
      @search_page = Integer(params[:page]).abs
      @search_page = 1 if @search_page.zero?
    rescue ArgumentError, TypeError
      @search_page = 1
    end

    begin
      @search_type = Integer(params[:type]).abs
    rescue ArgumentError, TypeError
      @search_type = 0
    end

    # TODO: Better benchmark timers (clicking on it opens a drawer which displays how long each step took)
    # Start a timer
    start_time = Time.now

    # Results -->
    case @search_type
    when 0 # Text search
      raw = google_text_search(@search_query, @search_page)
      @results = raw[:results]
      @max_pages = raw[:pages]
      @widgets = []

      puts @max_pages

      # Wikipedia ->
      wikipedia_result = get_wikipedia_summary(@results)
      @widgets << { type: 'wikipedia', content: wikipedia_result } if !wikipedia_result.nil?

      rendered_page = :search_text
    when 1 # Image search
      @search_engine = params[:engine] || Rails.configuration.inertia.search[:default_image_engine]
      case @search_engine
      when 'qwant'
        @results = qwant_image_search(@search_query)
      when 'bing'
      end

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
