# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

# Used to test root_path_without_url helper
# Also enable in application.rb & avo.rb (prefix_path)
# map "/development/internal-api" do
#   run Rails.application
# end

run Rails.application
