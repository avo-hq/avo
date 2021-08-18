require "rails_helper"
WebMock.disable_net_connect!

RSpec.feature "Avo::Licensing::HQ", type: :feature do
  describe ".response" do
    let(:request) { DummyRequest.new "127.0.0.1", "avodemo.herokuapp.test", 3001 }
    subject(:response) { Avo::Licensing::HQ.new(request).response }

    context "with community license" do
      before do
        Avo.configure do |config|
          config.license = "community"
        end
      end

      context "with valid response" do
        before do
          stub_request(:post, Avo::Licensing::HQ::ENDPOINT).with(body: hash_including({
            license: "community"
          }.stringify_keys)).to_return(status: 200, body: {id: "community", valid: true}.to_json, headers: json_headers)
        end

        it { is_expected.to include({id: "community", valid: true, expiry: 1.hour, license: "community", license_key: "license_123", environment: "test", ip: "127.0.0.1", host: "avodemo.herokuapp.test", port: 3001}.as_json) }

        it "caches the result" do
          expect(Rails.cache.read(Avo::Licensing::HQ::CACHE_KEY)).to be nil

          subject

          expect(Rails.cache.read(Avo::Licensing::HQ::CACHE_KEY)).not_to be nil
        end

        describe "when runs multiple times" do
          it "runs the request once" do
            subject
            subject
            subject

            expect(stub_request(:post, Avo::Licensing::HQ::ENDPOINT).with(body: hash_including({
              license: "community"
            }.stringify_keys))).to have_been_made.once
          end
        end
      end

      context "with 500 response" do
        before do
          stub_request(:post, Avo::Licensing::HQ::ENDPOINT).with(body: hash_including({
            license: "community"
          }.stringify_keys)).to_return({status: 500, body: "HQ Internal Server Error."}.as_json)
        end

        it "caches the error" do
          expect(Rails.cache.read(Avo::Licensing::HQ::CACHE_KEY)).to be nil

          subject

          expect(Rails.cache.read(Avo::Licensing::HQ::CACHE_KEY)).to include({error: "Avo HQ Internal server error.", exception_message: "HQ Internal Server Error.", expiry: 5.minutes}.as_json)
          expect(Rails.cache.read(Avo::Licensing::HQ::CACHE_KEY)).not_to include :valid
        end
      end

      context "with connection timeout error" do
        before do
          stub_request(:post, Avo::Licensing::HQ::ENDPOINT).with(body: hash_including({
            license: "community"
          }.stringify_keys)).to_timeout
        end

        it "caches the error" do
          expect(Rails.cache.read(Avo::Licensing::HQ::CACHE_KEY)).to be nil

          subject

          expect(Rails.cache.read(Avo::Licensing::HQ::CACHE_KEY)).to include({error: "Request timeout.", exception_message: "execution expired", expiry: 5.minutes}.as_json)
          expect(Rails.cache.read(Avo::Licensing::HQ::CACHE_KEY)).not_to include :valid
        end

        describe "when config for display is false" do
          let(:url) { "/admin/dashboard/" }

          before do
            Avo.configure do |config|
              config.display_license_request_timeout_error = false
            end
          end

          it "does not display the error" do
            expect(Rails.cache.read(Avo::Licensing::HQ::CACHE_KEY)).to be nil

            subject

            expect(Rails.cache.read(Avo::Licensing::HQ::CACHE_KEY)).to include({error: "Request timeout.", exception_message: "execution expired", expiry: 5.minutes}.as_json)
            expect(Rails.cache.read(Avo::Licensing::HQ::CACHE_KEY)).not_to include :valid

            visit url

            expect(page).not_to have_text "Avo HQ Error"
            expect(page).not_to have_text "Request timeout."
            expect(page).not_to have_text "Checking back every 5 minutes."
          end
        end

        describe "when config for display is true" do
          let(:url) { "/admin/dashboard/" }

          before do
            Avo.configure do |config|
              config.display_license_request_timeout_error = true
            end
          end

          it "does not display the error" do
            expect(Rails.cache.read(Avo::Licensing::HQ::CACHE_KEY)).to be nil

            subject

            expect(Rails.cache.read(Avo::Licensing::HQ::CACHE_KEY)).to include({error: "Request timeout.", exception_message: "execution expired", expiry: 5.minutes}.as_json)
            expect(Rails.cache.read(Avo::Licensing::HQ::CACHE_KEY)).not_to include :valid

            visit url

            expect(page).to have_text "Avo HQ Error"
            expect(page).to have_text "Request timeout."
            expect(page).to have_text "Checking back every 5 minutes."
          end
        end

        it "caches the error" do
          expect(Rails.cache.read(Avo::Licensing::HQ::CACHE_KEY)).to be nil

          subject

          expect(Rails.cache.read(Avo::Licensing::HQ::CACHE_KEY)).to include({error: "Request timeout.", exception_message: "execution expired", expiry: 5.minutes}.as_json)
          expect(Rails.cache.read(Avo::Licensing::HQ::CACHE_KEY)).not_to include :valid
        end

      end


      context "with connection error" do
        before do
          stub_request(:post, Avo::Licensing::HQ::ENDPOINT).with(body: hash_including({
            license: "community"
          }.stringify_keys)).to_raise SocketError.new "Connection error!"
        end

        it "caches the error" do
          expect(Rails.cache.read(Avo::Licensing::HQ::CACHE_KEY)).to be nil

          subject

          expect(Rails.cache.read(Avo::Licensing::HQ::CACHE_KEY)).to include({error: "Connection error.", exception_message: "Connection error!", expiry: 5.minutes}.as_json)
          expect(Rails.cache.read(Avo::Licensing::HQ::CACHE_KEY)).not_to include :valid
        end
      end
    end

    context "with pro license" do
      before do
        Avo.configure do |config|
          config.license = "pro"
        end
      end

      context "with valid response" do
        before do
          stub_request(:post, Avo::Licensing::HQ::ENDPOINT).with(body: hash_including({
            license: "pro",
            license_key: "license_123"
          }.stringify_keys)).to_return(status: 200, body: {id: "pro", valid: true}.to_json, headers: json_headers)
        end

        it { is_expected.to include({id: "pro", valid: true, expiry: 1.hour, license: "pro", license_key: "license_123", environment: "test", ip: "127.0.0.1", host: "avodemo.herokuapp.test", port: 3001}.as_json) }
      end

      context "with invalid response" do
        before do
          stub_request(:post, Avo::Licensing::HQ::ENDPOINT).with(body: hash_including({
            license: "pro",
            license_key: "license_123"
          }.stringify_keys)).to_return(status: 200, body: {id: "pro", valid: false}.to_json, headers: json_headers)
        end

        it { is_expected.to include({id: "pro", valid: false, expiry: 1.hour, license: "pro", license_key: "license_123", environment: "test", ip: "127.0.0.1", host: "avodemo.herokuapp.test", port: 3001}.as_json) }
      end
    end
  end
end
