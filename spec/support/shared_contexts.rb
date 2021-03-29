shared_context "has_admin_user" do
  let(:admin) { create :user, roles: {admin: true} }
end
