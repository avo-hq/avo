require "rails_helper"

# A host finds the settings that exist in the initializer `avo:install` writes, so an option left out of
# the template stays unknown to every new app.
RSpec.describe "The avo:install initializer template" do
  # Set through authenticate_with, current_user_method, set_context, set_initial_breadcrumbs or mount_avo,
  # kept as flat aliases of config.associations and config.sidebar, or obsolete.
  not_set_directly = %i[
    authenticate current_user context initial_breadcrumbs mount_lookbook
    associations_lookup_list_limit sidebar_toggle_visible
    mount_avo_engines
  ]

  it "names every option a host can set" do
    template = Avo::Engine.root.join("lib/generators/avo/templates/initializer/avo.tt").read
    options = Avo::Configuration.public_instance_methods(false).grep(/\A[a-z_]+=\z/).map { |writer| writer.to_s.chomp("=").to_sym }

    expect((options - not_set_directly).reject { |option| template.match?(/config\.#{option}\b/) }).to eq []
  end
end
