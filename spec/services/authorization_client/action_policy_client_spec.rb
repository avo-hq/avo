require "spec_helper"

RSpec.describe 'Avo::Services::AuthorizationClient::ActionPolicyClient' do
  let(:client) { described_class.new }

  let(:user) { double("User") }
  let(:policy) do
    Class.new(ActionPolicy::Base) do
      def can_i?
        false
      end

      def please?
        true
      end
    end
  end
  let(:record) { Dummy.new }

  around do |example|
    current_client = Avo.configuration.authorization_client
    Avo.configuration.authorization_client = :action_policy
    example.run
    Avo.configuration.authorization_client = current_client
  end

  before do
    stub_const "Dummy", Class.new
    stub_const "DummyPolicy", policy
  end

  describe "#policy" do
    it "returns the policy" do
      policy = client.policy(user, record)
      expect(policy).to be_an_instance_of(DummyPolicy)
    end

    it "raises exception when policy does not exist" do
      hide_const "DummyPolicy"
      expect { client.policy(user, record) }
        .to_not raise_error(Avo::Services::AuthorizationService::PolicyNotDefinedError)
    end
  end

  describe "#policy!" do
    it "returns the policy" do
      policy = client.policy!(user, record)
      expect(policy).to be_an_instance_of(DummyPolicy)
    end

    it "raises exception when policy does not exist" do
      hide_const "DummyPolicy"
      expect { client.policy!(user, record) }
        .to raise_error(Avo::Services::AuthorizationService::PolicyNotDefinedError)
    end
  end

  describe "#authorize" do
    it "raises exception to unauthorized actions" do
      expect { client.authorize(user, record, :can_i?) }
        .to raise_error(Avo::Services::AuthorizationService::NotAuthorizedError)
    end

    it "responds true to authorized actions" do
      expect(client.authorize(user, record, :please?)).to be true
    end
  end

  describe "#apply_policy!" do
    specify do
      expect_any_instance_of(policy).to receive(:apply_scope).with(record, type: :avo_scope)
      client.apply_policy!(user, record)
    end
  end
end
