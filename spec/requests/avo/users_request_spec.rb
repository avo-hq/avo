require "rails_helper"

RSpec.describe "UsersController", type: :request do
  let(:admin_user) { create :user, roles: {'admin': true} }
  let(:user) { create :user }
  let(:user_params) do
    {
      user: {
        first_name: "John",
        last_name: "Doe",
        email: "john@doe.com",
        password: "secret_password",
        password_confirmation: "secret_password"
      }
    }
  end

  before do
    login_as admin_user
  end

  describe "Controller hooks" do
    context "#create" do
      it "allows executing code after resource is created" do
        User.any_instance.should_receive(:notify).with("User created")

        post "/admin/resources/users", params: user_params
      end
    end

    context "#update" do
      it "allows executing code after resource is updated" do
        User.any_instance.should_receive(:notify).with("User updated")

        patch "/admin/resources/users/#{user.id}", params: user_params
      end
    end

    context "#destroy" do
      it "allows executing code after resource is destroyed" do
        expect { 
          delete "/admin/resources/users/#{user.id}", params: user_params 
        }.to output("User destroyed\n").to_stdout
      end
    end
  end
end
