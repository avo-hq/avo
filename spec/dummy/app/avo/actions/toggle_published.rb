class TogglePublished < Avo::BaseAction
  self.name = 'Toggle post published'
  self.message = 'Are you sure, sure?'
  self.confirm_button_label = 'Toggle'
  self.cancel_button_label = "Don't toggle yet"

  def handle(request, models, fields)
    models.each do |model|
      if model.published_at.present?
        model.update published_at: nil
      else
        model.update published_at: DateTime.now
      end
    end

    succeed 'Purrrfect!'
  end

  fields do |f|
    f.boolean :notify_user, default: true
    f.text :message, default: 'Your account has been marked as inactive.'
  end
end
