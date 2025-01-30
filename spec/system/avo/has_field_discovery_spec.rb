require "rails_helper"

RSpec.describe Avo::Concerns::HasFieldDiscovery, type: :system do
  let!(:user) { create :user, first_name: "John", last_name: "Doe", birthday: "1990-01-01", email: "john.doe@example.com" }
  let!(:post) { create :post, user: user, name: "Sample Post" }

  before do
    Avo::Resources::User.with_temporary_items do
      main_panel do
        discover_columns except: %i[email active is_admin? birthday is_writer outside_link custom_css]
        discover_associations only: %i[cv_attachment]

        sidebar do
          with_options only_on: :show do
            discover_columns only: %i[email], as: :gravatar, link_to_record: true, as_avatar: :circle
            field :heading, as: :heading, label: ""
            discover_columns only: %i[active], name: "Is active"
          end

          discover_columns only: %i[birthday]

          field :password, as: :password, name: "User Password", required: false, only_on: :forms, help: 'You may verify the password strength <a href="http://www.passwordmeter.com/" target="_blank">here</a>.'
          field :password_confirmation, as: :password, name: "Password confirmation", required: false, revealable: true

          with_options only_on: :forms do
            field :dev, as: :heading, label: '<div class="underline uppercase font-bold">DEV</div>', as_html: true
            discover_columns only: %i[custom_css]
          end
        end
      end

      discover_associations only: %i[posts]
      discover_associations except: %i[posts post cv_attachment]
    end
  end

  after do
    Avo::Resources::User.restore_items_from_backup
  end

  describe "Show Page" do
    let(:url) { "/admin/resources/users/#{user.slug}" }

    before { visit url }

    it "displays discovered columns correctly" do
      wait_for_loaded

      # Verify discovered columns
      expect(page).to have_text "FIRST NAME"
      expect(page).to have_text "John"
      expect(page).to have_text "LAST NAME"
      expect(page).to have_text "Doe"
      expect(page).to have_text "BIRTHDAY"
      expect(page).to have_text "1990-01-01"

      # Verify excluded fields are not displayed
      expect(page).not_to have_text "IS ADMIN?"
      expect(page).not_to have_text "CUSTOM CSS"
    end

    it "displays the email as a gravatar field with a link to the record" do
      within(".resource-sidebar-component") do
        expect(page).to have_css("img") # Check for avatar
      end
    end

    it "displays discovered associations correctly" do
      wait_for_loaded

      # Verify `posts` association
      expect(page).to have_text "Posts"
      expect(page).to have_text "Sample Post", wait: 5
      expect(page).to have_link "Sample Post", href: "/admin/resources/posts/#{post.slug}?via_record_id=#{user.slug}&via_resource_class=Avo%3A%3AResources%3A%3AUser"

      # Verify `cv_attachment` association is present
      expect(page).to have_text "CV"
    end

    it "renders each field exactly once" do
      wait_for_loaded

      within(".main-content-area") do
        within("[data-panel-id='main']") do
          # Basic fields
          ## Main Panel
          expect(page).to have_text("FIRST NAME", count: 1)
          expect(page).to have_text("LAST NAME", count: 1)
          expect(page).to have_text("ROLES", count: 1)
          expect(page).to have_text("TEAM ID", count: 1)
          expect(page).to have_text("CREATED AT", count: 1)
          expect(page).to have_text("UPDATED AT", count: 1)
          expect(page).to have_text("SLUG", count: 1)

          # Sidebar
          expect(page).to have_text("AVATAR", count: 1)
          expect(page).to have_text("IS ACTIVE", count: 1)
          expect(page).to have_text("BIRTHDAY", count: 1)

          # Single file uploads
          expect(page).to have_text("CV", count: 1)
          expect(page).not_to have_text("CV ATTACHMENT")
        end

        # Associations
        expect(page).to have_selector("#has_many_field_show_posts", count: 1)
      end
    end
  end

  describe "Index Page" do
    let(:url) { "/admin/resources/users" }

    before { visit url }

    it "lists discovered fields in the index view" do
      wait_for_loaded

      within("table") do
        expect(page).to have_text "John"
        expect(page).to have_text "Doe"
        expect(page).to have_text user.slug
      end
    end
  end

  describe "Form Page" do
    let(:url) { "/admin/resources/users/#{user.id}/edit" }

    before { visit url }

    it "displays form-specific fields" do
      wait_for_loaded

      # Verify form-only fields
      expect(page).to have_field "User Password"
      expect(page).to have_field "Password confirmation"

      # Verify custom CSS field is displayed
      expect(page).to have_text "CUSTOM CSS"

      # Verify password fields allow input
      fill_in "User Password", with: "new_password"
      fill_in "Password confirmation", with: "new_password"
    end

    it "renders each input field exactly once" do
      wait_for_loaded

      # Form fields
      expect(page).to have_text("FIRST NAME", count: 1)
      expect(page).to have_text("LAST NAME", count: 1)
      expect(page).to have_text("ROLES", count: 1)
      expect(page).to have_text("TEAM ID", count: 1)
      expect(page).to have_text("CREATED AT", count: 1)
      expect(page).to have_text("UPDATED AT", count: 1)
      expect(page).to have_text("SLUG", count: 1)

      # File upload fields
      expect(page).to have_text("CV", count: 1)

      # Password fields
      expect(page).to have_text("USER PASSWORD", count: 1)
      expect(page).to have_text("PASSWORD CONFIRMATION", count: 1)
    end
  end

  describe "Has One Attachment" do
    let(:url) { "/admin/resources/users/#{user.id}/edit" }

    before { visit url }

    it "displays single file upload correctly for has_one_attached" do
      wait_for_loaded

      within('[data-field-id="cv"]') do
        # Verify it shows "Choose File" instead of "Choose Files"
        expect(page).to have_css('input[type="file"]:not([multiple])')
      end
    end
  end

  describe "Trix Editor" do
    let(:event) { create :event }
    let(:url) { "/admin/resources/events/#{event.id}/edit" }

    after do
      Avo::Resources::Event.restore_items_from_backup
    end

    before do
      Avo::Resources::Event.with_temporary_items do
        discover_columns
      end
      visit url
    end

    it "renders Trix editor only once" do
      wait_for_loaded

      # Verify only one Trix editor instance is present
      expect(page).to have_css("trix-editor", count: 1)
    end
  end

  describe "Tags" do
    let(:post) { create :post }
    let(:url) { "/admin/resources/posts/#{post.id}" }

    after do
      Avo::Resources::Post.restore_items_from_backup
    end

    before do
      Avo::Resources::Post.with_temporary_items do
        discover_columns
      end
      visit url
    end

    it "renders tags correctly" do
      wait_for_loaded

      # Verify only one Trix editor instance is present
      expect(page).to have_text("TAGS", count: 1)
      expect(page).to have_css('[data-target="tag-component"]')
    end
  end

  describe "Enum Fields" do
    let(:post) { create :post }
    let(:url) { "/admin/resources/posts/#{post.id}/edit" }

    after do
      Avo::Resources::Post.restore_items_from_backup
    end

    before do
      Avo::Resources::Post.with_temporary_items do
        discover_columns
      end
      visit url
    end

    it "displays enum fields as select boxes" do
      wait_for_loaded

      within('[data-field-id="status"]') do
        expect(page).to have_css("select")
        expect(page).to have_select(options: ["draft", "published", "archived"])
        expect(page).to have_select(selected: post.status)
      end
    end
  end

  describe "Polymorphic Associations" do
    let(:post) { create :post }
    let(:comment) { create :comment, commentable: post }

    after do
      Avo::Resources::Comment.restore_items_from_backup
    end

    before do
      Avo::Resources::Comment.with_temporary_items do
        discover_associations
      end
      visit "/admin/resources/comments/#{comment.id}"
    end

    it "displays polymorphic association correctly" do
      wait_for_loaded

      within("[data-panel-id='main']") do
        expect(page).to have_text("COMMENTABLE")
        expect(page).to have_link(post.name, href: /\/admin\/resources\/posts\//)
      end
    end
  end

  describe "Ignored Fields" do
    before { visit "/admin/resources/users/#{user.slug}" }

    it "does not display sensitive fields" do
      wait_for_loaded

      within("[data-panel-id='main']") do
        expect(page).not_to have_text("ENCRYPTED_PASSWORD")
        expect(page).not_to have_text("RESET_PASSWORD_TOKEN")
        expect(page).not_to have_text("REMEMBER_CREATED_AT")
      end
    end
  end
end
