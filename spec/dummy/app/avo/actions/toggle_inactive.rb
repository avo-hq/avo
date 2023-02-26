class ToggleInactive < Avo::BaseAction
  self.name = "Toggle inactive"

  field :notify_user, as: :boolean, default: true
  field :message, as: :text, default: "Your account has been marked as inactive."
  field :user_id,
    as: :tags,
    mode: :select,
    close_on_select: true,
    fetch_values_from: -> { "/admin/resources/users/get_users?hey=you&record_id=#{resource.model.id}" },
    suggestions: -> do
      User.take(5).map do |user|
        {
          value: user.id,
          label: user.name
        }
      end
    end

  def handle(**args)
    models, fields, _ = args.values_at(:models, :fields, :current_user, :resource)
    # for testing purposes
    TestBuddy.hi(fields["user_id"])

    models.each do |model|
      if model.active
        model.update active: false
      else
        model.update active: true
      end

      model.notify fields[:message] if fields[:notify_user]
    end

    silent
  end
end
