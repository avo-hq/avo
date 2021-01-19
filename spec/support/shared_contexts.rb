RSpec.shared_context 'admin', admin: true do
  using TestProf::AnyFixture::DSL

  before(:all) do
    fixture(:admin) { create :user, roles: { admin: true } }
  end

  let(:admin) { fixture(:admin) }
end
