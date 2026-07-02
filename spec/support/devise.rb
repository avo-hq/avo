RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include Devise::Test::IntegrationHelpers

  config.before(:each, type: :feature) { Warden.test_mode! }
  config.after(:each, type: :feature) { Warden.test_reset! }
  config.before(:each, type: :system) { Warden.test_mode! }
  config.after(:each, type: :system) { Warden.test_reset! }
end
