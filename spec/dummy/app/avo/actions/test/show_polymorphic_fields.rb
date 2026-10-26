class Avo::Actions::Test::ShowPolymorphicFields < Avo::BaseAction
  self.name = "Show polymorphic fields"

  def fields
    field :reviewable, as: :belongs_to, polymorphic_as: :reviewable, types: [::Post, ::Team]
  end

  def handle(fields:, **)
    succeed "#{fields[:reviewable_type]} #{fields[:reviewable_id]}"
  end
end
