# The primary controller for the application
class ApplicationController < ActionController::Base
  def index
    @motd = Rails.configuration.inertia.motd
  end
end
