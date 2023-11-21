class Avo::Actions::DeleteComment < Avo::BaseAction
  self.name = "Delete"

  def handle(**args)
    records, _fields, _current_user, _resource = args.values_at(:records, :fields, :current_user, :resource)

    records.each(&:destroy!)
  end
end
