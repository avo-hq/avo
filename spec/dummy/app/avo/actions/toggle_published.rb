class TogglePublished < Avo::BaseAction
  self.name = 'Toggle post published'
  self.message = 'Are you sure, sure?'
  self.confirm_text = 'Toggle'
  self.cancel_text = "Don't toggle yet"

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

  def fields(request)
    f.boolean :notify_user, default: true
    f.text :message, default: 'Your account has been marked as inactive.'
  end
end
