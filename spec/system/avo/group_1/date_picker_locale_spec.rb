require "rails_helper"

RSpec.describe "Date picker locale", type: :system do
  describe "date time field" do
    let!(:comment) { create :comment, posted_at: Time.new(1988, 2, 10, 16, 22, 0, "UTC") }

    before do
      Avo::Resources::Comment.with_temporary_items do
        field :body, as: :textarea
        field :posted_at, as: :date_time, relative: false
      end
    end

    after do
      Avo::Resources::Comment.restore_items_from_backup
    end

    def open_picker
      find('[data-field-id="posted_at"] [data-controller="date-field"] input[type="text"]').click
    end

    it "shows the month and weekday names in the app locale" do
      visit avo.edit_resources_comment_path(comment, force_locale: :pt)

      open_picker

      within ".flatpickr-calendar.open" do
        expect(page).to have_css ".flatpickr-monthDropdown-month", text: "fevereiro"
        expect(page).to have_css ".flatpickr-weekday", text: "seg."
        expect(page).not_to have_css ".flatpickr-weekday", text: "Mon"
      end
    end

    it "keeps the english names on the default locale" do
      visit avo.edit_resources_comment_path(comment)

      open_picker

      within ".flatpickr-calendar.open" do
        expect(page).to have_css ".flatpickr-monthDropdown-month", text: "February"
        expect(page).to have_css ".flatpickr-weekday", text: "Mon"
      end
    end
  end

  describe "date time filter" do
    # The dummy app has no pt translations for the users filters and raises on the missing keys.
    around do |example|
      I18n.backend.store_translations(:pt, {
        avo: {
          filter_translations: {
            user_names_filter: {
              name: "Filtro de nomes",
              button_label: "Filtrar por nomes"
            }
          }
        }
      })

      example.run
    ensure
      I18n.backend.reload!
    end

    it "shows the weekday names in the app locale" do
      visit avo.resources_users_path(force_locale: :pt)

      expect(page).to have_css ".flatpickr-calendar .flatpickr-weekday", text: "seg.", visible: :all
    end
  end
end
