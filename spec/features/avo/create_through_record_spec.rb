require "rails_helper"

RSpec.feature "create_through_record", type: :feature do
  # create post on user
  describe "belongs_to" do
    let(:url) { "/admin/resources/posts/new?via_relation=user&via_relation_class=User&via_record_id=#{admin.id}" }

    it "attaches the user to the post" do
      expect(Post.count).to eq 0
      visit url

      fill_in "post_name", with: "post name"
      click_on "Save"

      wait_for_loaded

      post = Post.first
      expect(post.user).to eq admin
      expect(current_path).to eq "/admin/resources/users/#{admin.slug}"
    end
  end

  describe "belongs_to comment" do
    let(:url) { "/admin/resources/comments/new?via_relation=user&via_relation_class=User&via_record_id=#{admin.id}" }

    it "attaches the user to the team" do
      expect(Comment.count).to eq 0
      visit url

      fill_in "comment_body", with: "Comment body"
      click_on "Save"

      wait_for_loaded

      comment = Comment.last
      expect(comment.user).to eq admin
      expect(current_path).to eq "/admin/resources/users/#{admin.slug}"
    end
  end

  # create person on spouse
  describe "has_many" do
    let!(:person) { create :person }
    let(:url) { "/admin/resources/spouses/new?via_relation=spouses&via_relation_class=Person&via_record_id=#{person.id}" }

    it "attaches the spouse to a person" do
      expect(Person.count).to eq 1
      expect(person.spouses.first).to be nil
      visit url

      fill_in "person_name", with: "Mary"
      click_on "Save"

      wait_for_loaded

      spouse = Spouse.last
      expect(person.spouses.first).to eq spouse
      expect(current_path).to eq "/admin/resources/people/#{person.id}"
    end
  end

  # create user on team
  describe "has_many through" do
    let!(:team) { create :team }
    let(:url) { "/admin/resources/users/new?via_relation=teams&via_relation_class=Team&via_record_id=#{team.id}" }

    it "attaches the user to the team" do
      expect(User.count).to eq 1 # the admin is there
      visit url

      fill_in "user_first_name", with: "first"
      fill_in "user_last_name", with: "last"
      fill_in "user_email", with: "user@email.com"
      fill_in "user_password", with: "passpasspass"
      fill_in "user_password_confirmation", with: "passpasspass"
      click_on "Save"

      wait_for_loaded

      user = User.last
      expect(user.teams.first).to eq team
      expect(current_path).to eq "/admin/resources/teams/#{team.id}"
    end
  end

  # create project on user
  describe "has_and_belongs_to_many" do
    let(:url) { "/admin/resources/projects/new?via_relation=users&via_relation_class=User&via_record_id=#{admin.id}" }

    it "attaches the user to the team" do
      expect(Project.count).to eq 0
      visit url

      fill_in "project_name", with: "Projy"
      fill_in "project_users_required", with: "15"
      click_on "Save"

      wait_for_loaded

      project = Project.last
      expect(project.users.first).to eq admin
      expect(current_path).to eq "/admin/resources/users/#{admin.id}"
    end
  end

  # create create comment on user
  describe "polymorphic" do
    let!(:project) { create :project }
    let(:url) { "/admin/resources/comments/new?via_relation=commentable&via_relation_class=Project&via_record_id=#{project.id}" }

    it "attaches the user to the team" do
      expect(Comment.count).to eq 0
      visit url

      fill_in "comment_body", with: "Comment body"
      click_on "Save"

      wait_for_loaded

      comment = Comment.first
      expect(comment.commentable).to eq project
      expect(project.comments.first).to eq comment
      expect(current_path).to eq "/admin/resources/projects/#{project.id}"
    end
  end
end
