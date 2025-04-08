class Avo::Actions::UpdateProduct < Avo::BaseAction
  self.name = "Update Product"

  def handle(**args)
    records, _resource = args.values_at(:records, :resource)

    records.each do |record|
      record.update!(updated_at: Time.current)
    end

    reload_records(records)
  end
end
