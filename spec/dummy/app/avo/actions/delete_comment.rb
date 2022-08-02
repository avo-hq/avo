class DeleteComment < Avo::BaseAction
  self.name = 'Delete'

  def handle(**args)
    models, _fields, _current_user, _resource = args.values_at(:models, :fields, :current_user, :resource)

    models.each(&:destroy!)
  end
end
