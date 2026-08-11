require "rails_helper"

RSpec.describe "Resource hydration", type: :feature do
  let(:resource_manager) { Avo::Resources::ResourceManager.new }

  around do |example|
    previous_resource_manager = Avo::Current.resource_manager
    Avo::Current.resource_manager = resource_manager
    example.run
  ensure
    Avo::Current.resource_manager = previous_resource_manager
  end

  describe "belongs-to defaults" do
    let(:user) { create :user }
    let(:existing_parent) { user }
    let(:post) { Post.new(user: existing_parent) }
    let(:via_record_id) { user.to_param }
    let(:current_params) { {} }
    let(:resource) do
      Avo::Resources::Post.new(
        view: :new,
        params: {
          via_relation: "user",
          via_relation_class: "User",
          via_record_id: via_record_id
        }
      ).detect_fields
    end

    subject(:hydrate_resource) do
      resource.hydrate(
        record: post,
        view: Avo::ViewInquirer.new(:new)
      )
    end

    before do
      allow(Avo::Current).to receive(:params).and_return(current_params)
    end

    it "preserves the parent when current params omit the relation class" do
      expect { hydrate_resource }.not_to raise_error

      expect(post.user).to eq user
    end

    context "with complete relationship params" do
      let(:existing_parent) { nil }
      let(:current_params) { {via_relation_class: "User"} }

      it "assigns the parent" do
        hydrate_resource

        expect(post.user_id).to eq user.id
      end
    end

    context "without a relationship record ID" do
      let(:via_record_id) { nil }
      let(:current_params) { {via_relation_class: "User"} }

      it "preserves the parent without querying for it" do
        resource
        post
        user_queries = []
        subscriber = lambda do |_name, _started, _finished, _unique_id, payload|
          user_queries << payload[:sql] if payload[:sql].include?('FROM "users"')
        end

        ActiveSupport::Notifications.subscribed(subscriber, "sql.active_record") do
          hydrate_resource
        end

        expect(user_queries).to be_empty
        expect(post.user).to eq user
      end
    end
  end

  describe "polymorphic belongs-to defaults" do
    let(:project) { create :project }
    let(:review) { Review.new(reviewable: project) }
    let(:resource) do
      Avo::Resources::Review.new(
        view: :new,
        params: {
          via_relation: "reviewable",
          via_relation_class: "Project",
          via_record_id: project.to_param
        }
      ).detect_fields
    end
    let(:resource_manager) do
      Avo::Resources::ResourceManager.new.tap do |manager|
        manager.resources.reject! do |available_resource|
          available_resource.model_class == Project
        end
      end
    end

    subject(:hydrate_resource) do
      resource.hydrate(
        record: review,
        view: Avo::ViewInquirer.new(:new)
      )
    end

    before do
      allow(Avo::Current).to receive(:params).and_return({})
    end

    it "preserves the parent when its Avo resource is unavailable" do
      expect { hydrate_resource }.not_to raise_error

      expect(review.reviewable).to eq project
    end
  end
end
