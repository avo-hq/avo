# Reports the association panel the action was started from, in the modal and
# in the success message (avo-hq/avo#3165).
class Avo::Actions::Test::ShowParent < Avo::BaseAction
  self.name = "Show parent"
  self.standalone = true
  self.visible = -> { true }
  self.message = -> { parent_record.present? ? "parent=#{parent_resource.class} #{parent_record.to_param}" : "no parent" }

  def fields
    field :parent_name, as: :text, default: parent_record&.name
  end

  def handle(**)
    succeed parent_record.present? ? "parent=#{parent_resource.class} #{parent_record.to_param}" : "no parent"
  end
end
