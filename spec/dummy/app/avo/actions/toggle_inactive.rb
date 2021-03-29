class ToggleInactive < Avo::BaseAction
  self.name = "Toggle inactive"

  field :notify_user, as: :boolean, default: true
  field :message, as: :text, default: "Your account has been marked as inactive."

  def handle(models:, fields:)
    models.each do |model|
      if model.active
        model.update active: false
      else
        model.update active: true
      end

      model.notify fields[:message] if fields[:notify_user]
    end

    succeed "Perfect!"
  end
end
