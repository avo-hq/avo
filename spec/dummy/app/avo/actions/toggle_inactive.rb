class ToggleInactive < Avo::BaseAction
  self.name = 'Toggle inactive'

  def handle(models:, fields:)
    models.each do |model|
      if model.active
        model.update active: false
      else
        model.update active: true
      end

      model.notify fields[:message] if fields[:notify_user]
    end

    succeed 'Perfect!'
  end

  fields do |f|
    f.boolean :notify_user, default: true
    f.text :message, default: 'Your account has been marked as inactive.'
  end
end
