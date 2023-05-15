# Controller for the /search route
class SearchController < ApplicationController
  include GoogleHelper
  include QwantHelper
  include UrlHelper
  include WikipediaHelper
  include SpecialHelper

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
      raw = google_text_search(@search_query, @search_page - 1)
      @results = raw[:results]
      @max_pages = raw[:pages]
      @widgets = []

      # * Special Results -->

      # Priority Widgets ->
      # NOTE: The order here doesn't matter, as in a regular search,
      #       more than 1 priority widgets shouldn't appear.

      # IP/User Agent
      network_information = get_network_information(request, @search_query)
      @widgets << { type: 'network_information', content: network_information } unless !network_information

      # Conversion
      conversion = get_conversion(@search_query)
      @widgets << { type: 'conversion', content: conversion } unless !conversion

      # Wikipedia ->
      wikipedia_result = get_wikipedia_summary(@results)
      @widgets << { type: 'wikipedia', content: wikipedia_result } unless !wikipedia_result

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

  def opensearch
    config = Rails.configuration.inertia.host
    @protocol = config[:protocol]
    @hostname = config[:hostname]

    render layout: false, content_type: 'application/opensearchdescription+xml'
  end
end
