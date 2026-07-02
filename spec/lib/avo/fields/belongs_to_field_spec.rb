require "rails_helper"

RSpec.describe Avo::Fields::BelongsToField, type: :model do
  describe "#fill_field" do
    let(:post) { Post.new }
    let(:post_resource) { Avo::Resources::Post.new(record: post, view: Avo::ViewInquirer.new(:new)) }
    let(:user_resource) { Avo::Resources::User.new }
    let!(:out_of_scope_user) { create(:user, first_name: "OutOfScope") }
    let!(:in_scope_user) { create(:user, first_name: "InScope") }

    let(:field) do
      described_class.new(:user, attach_scope: -> { ::User.all })
        .hydrate(record: post, resource: post_resource, view: Avo::ViewInquirer.new(:new))
    end

    before do
      allow(field).to receive(:target_resource).with(record: post).and_return(user_resource)
      allow(field).to receive(:reflection).and_return(Post.reflect_on_association(:user))
      allow(Avo::Resources::User).to receive(:find_scope).and_return(User.where(id: in_scope_user.id))
    end

    it "resolves the associated record using attach_scope instead of only find_scope" do
      field.fill_field(post, :user_id, out_of_scope_user.id.to_s, {})

      expect(post.user_id).to eq(out_of_scope_user.id)
    end

    it "clears the association when the value is blank" do
      post.user_id = in_scope_user.id

      field.fill_field(post, :user_id, "", {})

      expect(post.user_id).to be_nil
    end
  end
end
