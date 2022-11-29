class ReleaseFish < Avo::BaseAction
  self.name = "Release fish"
  self.message = -> {
    "Are you sure you want to release the #{record.name}?"
  }

  field :message, as: :trix, help: "Tell the fish something before releasing."
  field :user, as: :belongs_to, searchable: true, visible: ->(resource:) {
    resource.params[:id].present?
  }

  def handle(models:, fields:, **)
    models.each do |model|
      model.release
    end

    # Try and find that user
    begin
      user = User.find fields[:user_id]
    rescue
    end

    message = ActionView::Base.full_sanitizer.sanitize fields[:message]

    succeed "#{models.count} fish released with message '#{message}' by #{user&.name}."
  end
end
