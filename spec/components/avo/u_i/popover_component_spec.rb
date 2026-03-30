require "rails_helper"

RSpec.describe Avo::UI::PopoverComponent, type: :component do
  describe "rendering" do
    before do
      render_inline(described_class.new) do |component|
        component.with_trigger { "Trigger" }
        component.with_items { "Item" }
      end
    end

    it "renders the panel with the popover-menu controller" do
      expect(page).to have_css('[data-controller="popover-menu"]')
    end

    it "renders the panel with popover=auto" do
      expect(page).to have_css('[popover="auto"]')
    end

    it "wires popovertarget on the trigger button to the panel id" do
      panel_id = page.find('[data-controller="popover-menu"]')[:id]
      expect(panel_id).to be_present
      expect(page).to have_css("button[popovertarget='#{panel_id}']")
    end

    it "applies trigger_classes to the trigger button" do
      render_inline(described_class.new(trigger_classes: "button button--size-md")) do |component|
        component.with_trigger { "Trigger" }
        component.with_items { "Item" }
      end

      expect(page).to have_css("button.popover-menu__trigger.button.button--size-md")
    end

    it "applies trigger_data as data attributes on the trigger button" do
      render_inline(described_class.new(trigger_data: {tippy: "tooltip", tippy_content: "Actions"})) do |component|
        component.with_trigger { "Trigger" }
        component.with_items { "Item" }
      end

      expect(page).to have_css('button[data-tippy="tooltip"][data-tippy-content="Actions"]')
    end

    it "renders trigger slot content inside the button" do
      render_inline(described_class.new) do |component|
        component.with_trigger { "<span class='my-icon'>icon</span>".html_safe }
        component.with_items { "Item" }
      end

      expect(page).to have_css("button.popover-menu__trigger .my-icon", text: "icon")
    end

    it "renders items inside the dropdown menu list" do
      render_inline(described_class.new) do |component|
        component.with_trigger { "Trigger" }
        component.with_items { "<a class='dropdown-menu__item'>First</a><a class='dropdown-menu__item'>Second</a>".html_safe }
      end

      expect(page).to have_css(".dropdown-menu__list .dropdown-menu__item", text: "First")
      expect(page).to have_css(".dropdown-menu__list .dropdown-menu__item", text: "Second")
    end

    it "applies classes to the panel" do
      render_inline(described_class.new(classes: "my-custom-panel")) do |component|
        component.with_trigger { "Trigger" }
        component.with_items { "Item" }
      end

      expect(page).to have_css(".popover-menu__panel.my-custom-panel")
    end

    it "renders nothing when trigger is absent" do
      render_inline(described_class.new) do |component|
        component.with_items { "Item" }
      end

      expect(page).not_to have_css("button.popover-menu__trigger")
    end

    it "renders nothing when items are absent" do
      render_inline(described_class.new) do |component|
        component.with_trigger { "Trigger" }
      end

      expect(page).not_to have_css(".popover-menu__panel")
    end
  end
end
