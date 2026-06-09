require "rails_helper"

# Unit 3 — associations wired to manual (`loading: :manual`) loading.
#
# A manual association renders an `Avo::ManualFrameComponent` placeholder: a
# `<turbo-frame>` with NO `src` and a "Load" button. Nothing is fetched until the
# user clicks Load, at which point the controller sets `src` to the deferred URL
# and the real association content swaps in.
RSpec.describe "Manual loading associations", type: :system do
  let!(:user) { create :user }

  describe "has_many with loading: :manual" do
    let!(:comment) { create :comment, user: user, commentable: user }

    it "shows a Load button, fetches nothing until clicked, then loads the real table" do
      Avo::Resources::User.with_temporary_items do
        field :first_name, as: :text
        field :comments, as: :has_many, loading: :manual
      end

      visit avo.resources_user_path(user)

      frame = find('turbo-frame[id="has_many_field_show_comments"]')

      # No `src` before the click: nothing is fetched on initial paint.
      expect(frame[:src]).to be_blank
      expect(frame).to have_button("Load Comments")
      # The real association table is NOT present yet.
      expect(frame).not_to have_selector("[data-resource-name='comments'][data-resource-id='#{comment.id}']")

      within(frame) { click_on "Load Comments" }
      wait_for_loaded

      # After the click the real association content (the table) is rendered —
      # not the manual placeholder again (no infinite-placeholder loop).
      expect(page).to have_selector("turbo-frame[id='has_many_field_show_comments'] [data-resource-name='comments'][data-resource-id='#{comment.id}']")
      expect(page).not_to have_button("Load Comments")
    ensure
      Avo::Resources::User.restore_items_from_backup
    end
  end

  describe "has_and_belongs_to_many with loading: :manual" do
    let!(:project) { create :project }

    before { user.projects << project }

    it "behaves identically to has_many (delegated component)" do
      Avo::Resources::User.with_temporary_items do
        field :first_name, as: :text
        field :projects, as: :has_and_belongs_to_many, loading: :manual
      end

      visit avo.resources_user_path(user)

      # HABTM reuses the HasManyField show component but keeps its own frame id.
      frame = find('turbo-frame[id="has_and_belongs_to_many_field_show_projects"]')

      expect(frame[:src]).to be_blank
      expect(frame).to have_button("Load Projects")
      expect(frame).not_to have_selector("[data-resource-name='projects'][data-resource-id='#{project.id}']")

      within(frame) { click_on "Load Projects" }
      wait_for_loaded

      expect(page).to have_selector("turbo-frame[id='has_and_belongs_to_many_field_show_projects'] [data-resource-name='projects'][data-resource-id='#{project.id}']")
      expect(page).not_to have_button("Load Projects")
    ensure
      Avo::Resources::User.restore_items_from_backup
    end
  end

  describe "has_one with loading: :manual" do
    context "with a present value" do
      let!(:comment) { create :comment, user: user, commentable: user }

      it "shows a Load button and loads the real content on click" do
        Avo::Resources::User.with_temporary_items do
          field :first_name, as: :text
          field :comment, as: :has_one, loading: :manual
        end

        visit avo.resources_user_path(user)

        frame = find('turbo-frame[id="has_one_field_show_comment"]')

        expect(frame[:src]).to be_blank
        expect(frame).to have_button("Load Comment")

        within(frame) { click_on "Load Comment" }
        wait_for_loaded

        # The real has_one record content loads (not the placeholder again).
        expect(page).to have_selector("turbo-frame[id='has_one_field_show_comment'] [data-field-id]")
        expect(page).not_to have_button("Load Comment")
      ensure
        Avo::Resources::User.restore_items_from_backup
      end
    end

    context "with a nil value" do
      it "falls through to the existing attach/create empty state (no Load button, no turbo-frame)" do
        # No comment is created for this user -> has_one value is nil.
        Avo::Resources::User.with_temporary_items do
          field :first_name, as: :text
          field :comment, as: :has_one, loading: :manual
        end

        visit avo.resources_user_path(user)

        # The nil-value path renders the attach/create empty-state panel, with no
        # manual frame and no Load button.
        expect(page).not_to have_selector('turbo-frame[id="has_one_field_show_comment"]')
        expect(page).not_to have_button("Load Comment")
        expect(page).to have_css(".state")
      ensure
        Avo::Resources::User.restore_items_from_backup
      end
    end
  end

  # Regression (R3 / switcher passthrough): a non-manual has_many inside a tab
  # must keep its `loading="lazy"` frame — it must NOT regress to eager and must
  # NOT be fetched on initial paint. Asserting `loading="lazy"` distinguishes
  # lazy from eager (a "content eventually appears" assertion would pass for an
  # eager frame too).
  describe "non-manual has_many inside a tab (regression)" do
    let!(:comment) { create :comment, user: user, commentable: user }

    it "still renders the frame with loading=\"lazy\" and is not fetched on initial paint" do
      Avo::Resources::User.with_temporary_items do
        field :first_name, as: :text
        tabs do
          tab title: "Comments tab" do
            field :comments, as: :has_many
          end
        end
      end

      visit avo.resources_user_path(user)

      frame = find('turbo-frame[id="has_many_field_show_comments"]', visible: :all)

      # The switcher injects loading="lazy" for non-manual in-tab fields. It must
      # carry a `src` (so Turbo will fetch on reveal) AND `loading="lazy"`.
      expect(frame["loading"]).to eq("lazy")
      expect(frame[:src]).to be_present
      # Not manual: no Load button.
      expect(page).not_to have_button("Load Comments")
    ensure
      Avo::Resources::User.restore_items_from_backup
    end
  end

  # The show component branches on `@field.manual?` BEFORE consuming the
  # switcher's hardcoded `turbo_frame_loading: :lazy`, so a manual association
  # inside a tab renders the placeholder regardless of that kwarg — proving the
  # switcher needs no change (zero blast radius).
  describe "manual has_many inside a tab" do
    let!(:comment) { create :comment, user: user, commentable: user }

    it "renders the Load-button placeholder (no src) even with the switcher's lazy kwarg" do
      Avo::Resources::User.with_temporary_items do
        field :first_name, as: :text
        tabs do
          tab title: "Comments tab" do
            field :comments, as: :has_many, loading: :manual
          end
        end
      end

      visit avo.resources_user_path(user)

      frame = find('turbo-frame[id="has_many_field_show_comments"]', visible: :all)

      # Manual wins: no `src` (so no fetch on reveal) and a Load button — even
      # though the switcher hardcodes `turbo_frame_loading: :lazy`. The frame is
      # NOT the lazy frame (which would carry a `src`).
      expect(frame[:src]).to be_blank
      expect(frame).to have_button("Load Comments", visible: :all)
    ensure
      Avo::Resources::User.restore_items_from_backup
    end
  end
end
