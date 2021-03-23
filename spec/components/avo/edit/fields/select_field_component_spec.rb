# require "rails_helper"

# RSpec.describe Avo::Edit::Fields::SelectFieldComponent, type: :component do
#   let(:project) { create :project }
#   let(:resource) { Avo::App.get_resource 'Project' }
#   def _current_user
#   end
#   # pending "add some examples to (or delete) #{__FILE__}"

#   it "renders something useful" do
#     Avo::App.init_fields
#     Avo::App.init_resources(nil)
#     resource.hydrate(model: project, view: :edit, user: _current_user)
#     # field = resource.get_fields(panel: nil, view_type: :table, reflection: nil).select |field|
#     #   # field.id =
#     # end
#     field = resource.get_fields(panel: nil, view_type: :table, reflection: nil).first
#     # abort resource.get_fields(panel: nil, view_type: :table, reflection: nil).first.inspect
#     # abort described_class.new(field: field, resource: resource, form: nil, displayed_in_modal: false).inspect
#     expect(
#       render_inline(described_class.new(field: field, resource: resource, form: nil, displayed_in_modal: false))
#     ).to include(
#       "Hello, components!"
#     )
#   end
# end
