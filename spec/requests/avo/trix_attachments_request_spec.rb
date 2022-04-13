require 'rails_helper'

RSpec.describe Avo::AttachmentsController, type: :request do
  let(:post) { create :post }

  it "uplaods a file" do
    path = Rails.root.join('dummy-file.txt')

    params = {
      "file" => Rack::Test::UploadedFile.new(path, 'application/txt', true),
      "Content-Type": "image/jpeg",
      # "file": #<ActionDispatch::Http::UploadedFile:0x0000000110bc9ad8 @tempfile=#<Tempfile:/var/folders/ld/5xssqlts4479dhwq89glxr8r0000gn/T/RackMultipart20220412-42164-d7yfcf.jpg>, @original_filename="ghost.jpg", @content_type="image/jpeg", @headers="Content-Disposition: form-data; name=\"file\"; filename=\"ghost.jpg\"\r\nContent-Type: image/jpeg\r\n">,
      "filename": "ghost.jpg", "attachment_key": "attachments", "resource_name": "posts", "id": "31"
    }
    # post :create, params: params
    post "/admin/avo_api/resources/posts/#{post.id}/attachments", params: params

  end
end
