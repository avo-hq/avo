shared_context "has_admin_user" do
  let(:admin) { create :user, roles: {admin: true} }
  let(:decorated_admin) { UserDecorator.decorate admin }
end
