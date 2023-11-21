class Avo::Actions::ToggleInactive < Avo::BaseAction
  self.name = "Toggle inactive"

  def fields
    field :notify_user, as: :boolean, default: true
    field :message, as: :text, default: "Your account has been marked as inactive."
  end

  def handle(**args)
    query, fields, _ = args.values_at(:query, :fields, :current_user, :resource)
    # for testing purposes
    TestBuddy.hi(fields["user_id"])

    query.each do |record|
      if record.active
        record.update active: false
      else
        record.update active: true
      end

      record.notify fields[:message] if fields[:notify_user]
    end

    silent
  end
end
