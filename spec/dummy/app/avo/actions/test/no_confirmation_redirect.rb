class Avo::Actions::Test::NoConfirmationRedirect < Avo::BaseAction
  self.name = "Test No Confirmation Redirect"
  self.confirmation = false
  self.standalone = true

  def handle(**args)
    redirect_to main_app.hey_path
  end
end
