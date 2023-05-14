# The primary controller for the application
class ApplicationController < ActionController::Base
  def index
    @motd = config[:motd]
  end
end
