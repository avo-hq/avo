# avo/index/resource_table_component
module TestHelpers
  module AvoHelpers
    def find_component(name)
      find("[data-component-name=\"#{name.to_s.underscore}\"]")
    end

    def expect_missing_component(name)
      expect(page).not_to have_css "[data-component-name=\"#{name.to_s.underscore}\"]"
    end
  end
end
