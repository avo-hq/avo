module TestHelpers
  module FilterHelpers
    def visit_with_filters(filters = [])
      filters_as_params = filters
        .map do |filter|
          id, condition, value = filter

          "filters[#{id}][#{condition}][]=#{value}"
        end
        .join("&")

      visit "#{filters_path}?#{filters_as_params}"
    end

    def expect_record_not_present(name)
      within(find_component(Avo::Index::ResourceTableComponent)) do |el|
        expect(el).not_to have_text name
      end
    end

    def expect_record_present(name)
      within(find_component("avo/index/resource_table_component")) do |el|
        expect(el).to have_text name
      end
    end
  end
end
