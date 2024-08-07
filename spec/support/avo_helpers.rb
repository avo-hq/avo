# avo/index/resource_table_component
module TestHelpers
  module AvoHelpers
    def find_component(name)
      find("[data-component-name=\"#{name.to_s.underscore}\"]")
    end

    def expect_missing_component(name)
      expect(page).not_to have_css "[data-component-name=\"#{name.to_s.underscore}\"]"
    end

    def with_temporary_class_option(_class, option_name, option_value, &block)
      previous_value =  _class.send(option_name)
      _class.send(:"#{option_name}=", option_value)

      block.call

      _class.send(:"#{option_name}=", previous_value)
    end
  end
end
