class ApplicationController < ActionController::Base
  # load_defaults already turns this on, but CodeQL cannot read its version from ENV["RAILS_VERSION"].
  protect_from_forgery with: :exception
end
