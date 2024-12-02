class Avo::Actions::ToggleInactive < Avo::BaseAction
  self.name = "Toggle inactive"

  def fields
    field :notify_user, as: :boolean, default: true
    field :message, as: :text, default: "Your account has been marked as inactive."
    field :user_id,
      as: :tags,
      mode: :select,
      close_on_select: true,
      fetch_values_from: -> {
        # record is nil when selecting on index
        "/admin/resources/users/get_users?hey=you&record_id=#{resource&.record&.id}"
      },
      suggestions: -> do
        User.take(5).map do |user|
          {
            value: user.id,
            label: user.name
          }
        end
      end
  end

  def handle(**args)
    query, fields, _ = args.values_at(:query, :fields, :current_user, :resource)
    # for testing purposes
    TestBuddy.hi(fields["user_id"])

    query.each do |record|
      record.update! active: !record.active

      record.notify fields[:message] if fields[:notify_user]
    end

    silent

    reload_records(query)
  end
end
