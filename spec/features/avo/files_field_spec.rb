require "rails_helper"

RSpec.feature Avo::ProjectsController, type: :controller do
  context "create" do
    let(:file1) { create_file_blob(filename: "apple-touch-icon.png") }
    let(:file2) { create_file_blob(filename: "apple-touch-icon-precomposed.png") }

    it "creates a project with multiple files" do
      post :create, params: {
        project: {name: "Project X", users_required: "15", files: ["", file1.signed_id, file2.signed_id]}
      }

      project = Project.find_by(name: "Project X", users_required: "15")
      expect(project).not_to be_nil
      expect(response).to redirect_to(resources_project_path(project))
      expect(project.files.map(&:blob).map(&:filename).map(&:to_s))
        .to contain_exactly("apple-touch-icon.png", "apple-touch-icon-precomposed.png")
    end
  end

  # from https://github.com/rails/rails/blob/4a17b26c6850dd0892dc0b58a6a3f1cce3169593/activestorage/test/test_helper.rb#L52
  def create_file_blob(filename: "image.png", content_type: "image/png", metadata: nil)
    ActiveStorage::Blob.create_and_upload! io: file_fixture(filename).open,
      filename: filename, content_type: content_type, metadata: metadata
  end
end
