shared_context "with isolated plugin manager" do
  # Avo.boot mutates a process-wide singleton (Avo.plugin_manager). Specs that
  # call Avo.boot directly to exercise its concurrency behavior register fake
  # plugins/engines under it. Swap in a throwaway manager for the example so
  # Avo.boot's begin_reload/commit_reload mutate *that* instance instead of
  # the real (rails_helper-booted) one -- reassigning the ivar back to the
  # same original object would not undo the mutation, since commit_reload
  # changes that object's own @plugins/@engines in place.
  around do |example|
    original_manager = Avo.instance_variable_get(:@plugin_manager)
    Avo.instance_variable_set(:@plugin_manager, Avo::PluginManager.new)
    example.run
  ensure
    Avo.instance_variable_set(:@plugin_manager, original_manager)
  end
end

shared_context "has_admin_user" do
  let(:admin) { create :user, roles: {admin: true} }

  before :each do
    # Because Current runs on threads it won't work as expected in tests.
    # We need to simulate it.
    allow(Avo::Current).to receive(:context).and_return({
      foo: "bar",
      user: admin,
      params: {}
    })
  end
end
