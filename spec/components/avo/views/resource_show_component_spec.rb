require "rails_helper"

RSpec.describe Avo::Views::ResourceShowComponent, type: :component do
  describe "back link" do
    let(:user) { create :user }
    let(:params) { {} }
    let(:resource) { Avo::Resources::User.new(record: user, view: Avo::ViewInquirer.new("show")) }
    let(:component) { described_class.new(resource: resource) }
    let(:test_request) do
      ActionDispatch::TestRequest.create
        .tap do |req|
          req.env["HTTP_REFERER"] = "/admin/resources/users?" + Rack::Utils.build_query(params)
        end
    end
    let(:test_controller) do
      Avo::UsersController.new
        .tap { |c| c.request = test_request }
        .extend(Rails.application.routes.url_helpers)
    end

    it "returns the correct path" do
      test_controller.view_context.render(component)

      expect(component.back_path).to eq("/admin/resources/users")
    end

    context "when the resource is accessed via some page" do
      let(:params) { {page: 42} }

      it "returns path with page" do
        test_controller.view_context.render(component)

        expect(component.back_path).to eq("/admin/resources/users?page=42")
      end
    end
  end
end
