class Avo::Actions::Test::NoConfirmationPostsRedirect < Avo::BaseAction
  self.name = "Redirect to Posts"
  self.no_confirmation = true
  self.standalone = true

  def handle(**args)
    redirect_to avo.resources_posts_path
  end
end
