Avo.configure do |config|
  config.root_path = '/avo'
  config.app_name = 'Avocadelicious'
  config.license = 'pro'
  config.locale = 'en-US'
  config.license_key = ENV['AVO_LICENSE_KEY']
end
