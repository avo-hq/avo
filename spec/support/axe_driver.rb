RSpec.configure do |config|
  config.before(:each, a11y: true) do
    driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1024]
  end
end
