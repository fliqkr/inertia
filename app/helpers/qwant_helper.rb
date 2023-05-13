# A helper for Qwant related searches
module QwantHelper
  # Some variables from the configuration
  config = Rails.configuration.inertia.qwant

  TLD = config[:tld]
  USER_AGENT = config[:user_agent]
end
