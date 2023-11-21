require "rails_helper"

RSpec.describe "TabsPanelsAndSidebarVisibility", type: :feature do
  after do
    Avo::Resources::Spouse.restore_items_from_backup
  end

  before do
    Avo::Resources::Spouse.with_temporary_items do
      main_panel do
        field :id, as: :id
        field :name, as: :text

        sidebar do
          field :hidden_field_inside_sidebar, as: :text, visible: -> {
            resource.record.name == "RSpec TabsPanelAndSidebarVisibility"
          }
        end
      end

      tabs do
        field :hidden_field_inside_tabs, as: :text, visible: -> {
          resource.record.name == "RSpec TabsPanelAndSidebarVisibility"
        }

        tab "Hidden tab inside tabs" do
          field :hidden_field_inside_tabs_inside_tab, as: :text, visible: -> {
            resource.record.name == "RSpec TabsPanelAndSidebarVisibility"
          }

          panel do
            field :hidden_field_inside_tabs_inside_tab_inside_panel, as: :text, visible: -> {
              resource.record.name == "RSpec TabsPanelAndSidebarVisibility"
            }
          end
        end
      end
    end
  end

  describe "tabs" do
    let!(:visible_fields_spouse) { create :spouse, name: "RSpec TabsPanelAndSidebarVisibility" }
    let(:url_with_visible_fields_first_tab) {
      "/admin/resources/spouses/#{visible_fields_spouse.id}?active_tab_name=Hidden+field+inside+tabs&tab_turbo_frame=avo-tabgroup-2"
    }
    let(:url_with_visible_fields_second_tab) {
      "/admin/resources/spouses/#{visible_fields_spouse.id}?active_tab_name=Hidden+tab+inside+tabs&tab_turbo_frame=avo-tabgroup-2"
    }

    let!(:not_visible_fields_spouse) { create :spouse }
    let(:url_with_not_visible_fields) { "/admin/resources/spouses/#{not_visible_fields_spouse.id}" }

    context "none hidden" do
      it "find all tabs and fields" do
        visit url_with_visible_fields_first_tab
        expect(page).to have_text "Hidden field inside tabs"
        expect(page).to have_text "Hidden field inside sidebar"

        visit url_with_visible_fields_second_tab
        expect(page).to have_text "Hidden field inside tabs inside tab"
        expect(page).to have_text "Hidden field inside tabs inside tab inside panel"
        expect(page).to have_text "Hidden field inside sidebar"
      end
    end

    context "all hidden" do
      it "don't find any tabs and fields" do
        visit url_with_not_visible_fields
        expect(page).not_to have_text "Hidden field inside tabs"
        expect(page).not_to have_text "Hidden field inside sidebar"
        expect(page).not_to have_text "Hidden field inside tabs inside tab"
        expect(page).not_to have_text "Hidden field inside tabs inside tab inside panel"
        expect(page).not_to have_text "Hidden field inside sidebar"
      end
    end
  end
end
