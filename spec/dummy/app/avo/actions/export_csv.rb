class ExportCsv < Avo::BaseAction
  self.name = "Export csv"
  self.no_confirmation = false
  self.may_download_file = true

  def handle(**args)
    models, resource = args.values_at(:models, :resource)

    return error "No record selected" if models.blank?

    attributes = get_attributes models.first

    file = CSV.generate(headers: true) do |csv|
      csv << attributes

      models.each do |record|
        csv << attributes.map do |attr|
          record.send(attr)
        end
      end
    end

    download file, "#{resource.plural_name}.csv"
  end

  def get_attributes(record)
    # return ["id", "created_at"] # uncomment this and fill in for custom model properties

    record.class.columns_hash.keys
  end
end
