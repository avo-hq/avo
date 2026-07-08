class Avo::Actions::Test::NoConfirmationPostsRedirect < Avo::BaseAction
  self.name = "Redirect to Posts"
  self.confirmation = false
  self.standalone = true

  def handle(**args)
    redirect_to avo.resources_posts_path
  end
end
