class PhotoFilter < Avo::Filters::SelectFilter
  self.name = "Photo filter"

  def apply(request, query, value)
    case value
    when "photo"
      query.joins(:photo_attachment)
    when "no_photo"
      query.left_joins(:photo_attachment).where("active_storage_attachments.id is NULL")
    else
      query
    end
  end

  def options
    {
      photo: "With Photo",
      no_photo: "Without Photo"
    }
  end
end
