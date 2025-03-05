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
