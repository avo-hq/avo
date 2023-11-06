class Update < Avo::BaseAction
  self.name = "Update"
  self.message = ""
  self.visible = -> do
    false
  end

  {
    first_name: :text,
    last_name: :text,
    user_email: :text,
    active: :boolean,
    admin: :boolean
  }.each do |field_name, field_type|
    field field_name.to_sym, as: field_type, visible: -> (resource:) {
      Avo::Services::EncryptionService.decrypt(
        message: Base64.decode64(resource.params[:arguments]),
        purpose: :action_arguments
      ).dig("render_#{field_name}".to_sym)
    }
  end

  def handle(models:, fields:, **args)
    non_roles_fields = fields.slice!(:admin)

    models.each { |model| model.update!(non_roles_fields) }

    fields.each do |field_name, field_value|
      models.each { |model|  model.update! roles: model.roles.merge!({"#{field_name}": field_value}) }
    end

    succeed "User(s) updated!"
  end
end
