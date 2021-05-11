class ToggleAdmin < Avo::BaseAction
  self.name = "Toggle admin"
  self.no_confirmation = true

  def handle(models:, fields:)
    models.each do |model|
      if model.roles["admin"].present?
        model.update roles: model.roles.merge!({"admin": false})
      else
        model.update roles: model.roles.merge!({"admin": true})
      end
    end

    succeed "New admin(s) on the board!"
  end
end
