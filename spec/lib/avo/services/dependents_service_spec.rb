require "rails_helper"

RSpec.describe Avo::Services::DependentsService do
  # Subclasses keep the dependent chains local to this spec; the dummy models stay untouched.
  before do
    stub_const("CascadePost", Class.new(Post) {
      has_many :notes, as: :commentable, class_name: "Comment", dependent: :destroy
    })
    stub_const("CascadeUser", Class.new(User) {
      has_many :articles, foreign_key: :user_id, class_name: "CascadePost", dependent: :destroy
    })
    stub_const("WipingUser", Class.new(User) {
      has_many :articles, foreign_key: :user_id, class_name: "CascadePost", dependent: :delete_all
    })
  end

  let(:user) { create :user }
  let!(:first_post) { create :post, user: user }
  let!(:second_post) { create :post, user: user }

  before do
    create_list :comment, 3, commentable: first_post
    create :comment, commentable: second_post
    create :comment, commentable: create(:post)
  end

  # Posts are taggable, and their taggings and tag_taggings associations both reach the same 8 rows.
  it "counts every level the destroy cascades through, each record once" do
    expect(described_class.new(CascadeUser.find(user.id)).summary).to eq "2 articles, 8 taggings, and 4 notes"
  end

  it "stops at delete_all, which skips the callbacks that would cascade" do
    expect(described_class.new(WipingUser.find(user.id)).summary).to eq "2 articles"
  end

  it "names an association by its model attribute translation when there is one" do
    I18n.backend.store_translations :en, activerecord: {attributes: {cascade_user: {articles: {one: "Artikel", other: "Artikels"}}}}

    expect(described_class.new(CascadeUser.find(user.id)).summary).to eq "2 Artikels, 8 taggings, and 4 notes"
  ensure
    I18n.backend.reload!
  end
end
