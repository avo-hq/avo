class Avo::Actions::UpdateProduct < Avo::BaseAction
  self.name = "Update Product"

  def handle(**args)
    records, resource = args.values_at(:records, :resource)
    view_type = arguments[:view_type]

    records.each do |record|
      record.update!(updated_at: Time.current)
    end

    reload_records(records, view_type: view_type)
  end
end

