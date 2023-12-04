class Avo::Actions::Test::NoConfirmationRedirect < Avo::BaseAction
  self.name = "Test No Confirmation Redirect"
  self.no_confirmation = true
  self.standalone = true

  def handle(**args)
    redirect_to main_app.hey_path
  end
end
