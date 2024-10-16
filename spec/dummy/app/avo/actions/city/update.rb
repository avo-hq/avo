class Avo::Actions::City::Update < Avo::BaseAction
  self.name = "Update"
  self.visible = -> { false }

  def fields
    field :name, as: :text if arguments[:render_name]
    field :population, as: :number if arguments[:render_population]
  end

  def handle(**args)
    City.find(arguments[:cities]).each do |city|
      city.update! args[:fields]
    end

    succeed "City updated!"
    close_modal

    append_to_response -> {
      table_row_components = []
      header_fields = []

      City.find(@action.arguments[:cities]).each do |city|
        resource = @resource.dup
        resource.hydrate(record: city, view: :index)
        resource.detect_fields
        row_fields = resource.get_fields(only_root: true)
        header_fields.concat row_fields
        table_row_components << resource.resolve_component(Avo::Index::TableRowComponent).new(
          resource: resource,
          header_fields: row_fields.map(&:table_header_label),
          fields: row_fields
        )
      end

      header_fields_ids = header_fields.uniq!(&:table_header_label).map(&:table_header_label)

      table_row_components.map.with_index do |table_row_component, index|
        table_row_component.header_fields = header_fields_ids
        turbo_stream.replace(
          "row_#{@action.arguments[:cities][index]}",
          table_row_component
        )
      end
    }
  end
end
