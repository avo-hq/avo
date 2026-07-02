require "rails_helper"

RSpec.describe Avo::Services::HqReporter do
  let(:endpoint) { Avo::Services::HqReporter::ENDPOINT }
  let(:request_info) { {ip: "127.0.0.1", host: "localhost", port: 3000} }

  before do
    # Stub production environment
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
    # Clear cache before each test
    Avo.configuration.cache_store.delete(described_class.cache_key)
    # Reset plugin manager
    allow(Avo.plugin_manager).to receive(:installed?).with("avo-licensing").and_return(false)
  end

  describe ".report" do
    context "when send_metadata is enabled (default)" do
      before do
        Avo.configuration.send_metadata = true
      end

      it "sends payload with avo_metadata" do
        stub = stub_request(:post, endpoint)
          .with { |request|
            body = JSON.parse(request.body)
            body["avo_metadata"].is_a?(Hash) && body["avo_metadata"] != "disabled"
          }
          .to_return(status: 200, body: "{}")

        described_class.report(request_info)

        expect(stub).to have_been_requested
      end

      it "includes request info in payload" do
        stub = stub_request(:post, endpoint)
          .with { |request|
            body = JSON.parse(request.body)
            body["ip"] == "127.0.0.1" &&
              body["host"] == "localhost" &&
              body["port"] == 3000
          }
          .to_return(status: 200, body: "{}")

        described_class.report(request_info)

        expect(stub).to have_been_requested
      end

      it "includes version info in payload" do
        stub = stub_request(:post, endpoint)
          .with { |request|
            body = JSON.parse(request.body)
            body["avo_version"] == Avo::VERSION &&
              body["rails_version"] == Rails::VERSION::STRING &&
              body["ruby_version"] == RUBY_VERSION
          }
          .to_return(status: 200, body: "{}")

        described_class.report(request_info)

        expect(stub).to have_been_requested
      end
    end

    context "when send_metadata is disabled" do
      before do
        Avo.configuration.send_metadata = false
      end

      after do
        Avo.configuration.send_metadata = true
      end

      it "sends payload with avo_metadata as disabled" do
        stub = stub_request(:post, endpoint)
          .with { |request|
            body = JSON.parse(request.body)
            body["avo_metadata"] == "disabled"
          }
          .to_return(status: 200, body: "{}")

        described_class.report(request_info)

        expect(stub).to have_been_requested
      end
    end

    context "when avo-licensing is installed" do
      before do
        allow(Avo.plugin_manager).to receive(:installed?).with("avo-licensing").and_return(true)
      end

      it "does not send any request" do
        stub = stub_request(:post, endpoint)

        described_class.report(request_info)

        expect(stub).not_to have_been_requested
      end
    end

    context "when already reported within cache time" do
      before do
        Avo.configuration.cache_store.write(
          described_class.cache_key,
          {reported_at: Time.now},
          expires_in: described_class::CACHE_TIME
        )
      end

      it "does not send any request" do
        stub = stub_request(:post, endpoint)

        described_class.report(request_info)

        expect(stub).not_to have_been_requested
      end
    end

    context "when cache has expired" do
      before do
        Avo.configuration.cache_store.write(
          described_class.cache_key,
          {reported_at: Time.now - 25.hours},
          expires_in: described_class::CACHE_TIME
        )
      end

      it "sends a new request" do
        stub = stub_request(:post, endpoint).to_return(status: 200, body: "{}")

        described_class.report(request_info)

        expect(stub).to have_been_requested
      end
    end

    context "when not in production environment" do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
      end

      it "does not send any request" do
        stub = stub_request(:post, endpoint)

        described_class.report(request_info)

        expect(stub).not_to have_been_requested
      end
    end

    context "when request fails" do
      it "silently swallows the error" do
        stub_request(:post, endpoint).to_raise(StandardError.new("Network error"))

        expect { described_class.report(request_info) }.not_to raise_error
      end
    end
  end
end
