class Avo::Actions::TogglePublished < Avo::BaseAction
  self.name = "Toggle post published"
  self.message = "Are you sure, sure?"
  self.confirm_button_label = "Toggle"
  self.cancel_button_label = "Don't toggle yet"

  def fields
    field :notify_user, as: :boolean, default: true
    field :message, as: :text, default: "Your account has been marked as inactive."
  end

  def handle(**args)
    records, _ = args.values_at(:records, :fields, :current_user, :resource)

    records.each do |record|
      if record.published_at.present?
        record.update published_at: nil
      else
        record.update published_at: DateTime.now
      end
    end

    succeed "Purrrfect!"
  end
end
