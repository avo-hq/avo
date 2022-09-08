class ReleaseFish < Avo::BaseAction
  self.name = "Release fish"
  self.message = "Are you sure you want to release this fish?"

  field :message, as: :textarea, help: "Tell the fish something before releasing."
  field :user, as: :belongs_to, searchable: true

  def handle(**args)
    models, fields, _, _ = args.values_at(:models, :fields, :current_user, :resource)

    models.each do |model|
      model.release
    end

    # Try and find that user
    begin
      user = User.find fields["user_id"]
    rescue
    end

    succeed "#{models.count} fish released with message '#{fields["message"]}' by #{user&.name}."
  end
end
