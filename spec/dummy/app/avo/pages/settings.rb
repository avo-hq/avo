class Avo::Pages::Settings < Avo::Core::Pages::Base
  self.title = "Settings"
  self.description = "Manage your settings"
  self.instructions = "This is the settings page. You can manage your settings here. Navigate to the sub-pages to manage your settings."
  self.menu_entry = true

  def sub_pages
    # TODO: chose default sub page that renders when this page is opened
    sub_page Avo::Pages::Settings::General
    sub_page Avo::Pages::Settings::Notifications
    sub_page Avo::Pages::Settings::Integrations
  end

  # def forms
  #   form Avo::Forms::Settings::General
  # end
end
