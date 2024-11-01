require "rails_helper"

RSpec.feature "ResourceControlsPlacement", type: :feature do
  let!(:comment) { create :comment }

  around do |example|
    original_placement = Avo.configuration.resource_controls_placement
    example.run
    Avo.configuration.resource_controls_placement = original_placement
  end

  describe "with controls on the left" do
    it "shows to the left when configured from Avo.configuration" do
      Avo.configuration.resource_controls_placement = :left
      visit "/admin/resources/comments"

      within find("table") do
        # XPath containing the index of the cell
        expect(page).to have_xpath("tbody/tr[1]/td[1][@data-control='resource-controls']")
      end
    end

    it "shows to the left when configured from resource configuration" do
      with_temporary_class_option(Avo::Resources::Comment, :controls_placement, :left) do
        visit "/admin/resources/comments"

        within find("table") do
          # XPath containing the index of the cell
          expect(page).to have_xpath("tbody/tr[1]/td[1][@data-control='resource-controls']")
        end
      end
    end
  end

  describe "with controls on the right" do
    it "shows to the right when configured from Avo.configuration" do
      Avo.configuration.resource_controls_placement = :right
      visit "/admin/resources/comments"

      within find("table") do
        # XPath containing the index of the cell
        expect(page).to have_xpath("tbody/tr[1]/td[6][@data-control='resource-controls']")
      end
    end

    it "shows to the right when configured from resource configuration" do
      with_temporary_class_option(Avo::Resources::Comment, :controls_placement, :right) do
        visit "/admin/resources/comments"

        within find("table") do
          # XPath containing the index of the cell
          expect(page).to have_xpath("tbody/tr[1]/td[6][@data-control='resource-controls']")
        end
      end
    end
  end

  describe "with controls on both sides" do
    it "shows on both sides when configured from Avo.configuration" do
      Avo.configuration.resource_controls_placement = :both
      visit "/admin/resources/comments"

      within find("table") do
        # XPath containing the index of the cell
        expect(page).to have_xpath("tbody/tr[1]/td[1][@data-control='resource-controls']")
        expect(page).to have_xpath("tbody/tr[1]/td[7][@data-control='resource-controls']")
      end
    end

    it "shows on both sides when configured from resource configuration" do
      with_temporary_class_option(Avo::Resources::Comment, :controls_placement, :both) do
        visit "/admin/resources/comments"

        within find("table") do
          # XPath containing the index of the cell
          expect(page).to have_xpath("tbody/tr[1]/td[1][@data-control='resource-controls']")
          expect(page).to have_xpath("tbody/tr[1]/td[7][@data-control='resource-controls']")
        end
      end
    end
  end
end
