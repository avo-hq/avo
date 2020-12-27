Avo.configure do |config|
  ## == Routing ==
  config.root_path = '/<%= options[:path] %>'

  ## == Licensing ==
  config.license = 'community'
  # config.license_key = ENV['AVO_LICENSE_KEY']

  ## == Authentication ==
  # config.current_user_method(&:current_user)
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end

  ## == Authorization ==
  # config.authorization_methods = {
  #   index: 'index?',
  #   show: 'show?',
  #   edit: 'edit?',
  #   new: 'new?',
  #   update: 'update?',
  #   create: 'create?',
  #   destroy: 'destroy?',
  # }

  ## == Localization ==

  ## == Customization ==
  # config.app_name = 'Avocadelicious'
  # config.locale = 'en-US'
  # config.timezone = 'UTC'
  # config.currency = 'USD'
  # config.per_page = 24
  # config.per_page_steps = [12, 24, 48, 72]
  # config.via_per_page = 8
  # config.default_view_type = :table

  ## == Beta version ==
  # config.hide_resource_overview_component = false
  # config.hide_documentation_link = false
end
