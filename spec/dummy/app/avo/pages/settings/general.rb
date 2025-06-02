class Avo::Pages::Settings::General < Avo::Core::Pages::Base
  self.title = "General"
  self.description = "Manage your general settings"

  def forms
    # form Avo::Forms::Settings::General

    form Avo::Forms::Settings::AppSettings
    form Avo::Forms::Settings::ProfileSettings
  end
end