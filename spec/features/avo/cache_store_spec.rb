require "rails_helper"

RSpec.describe "Avo status and cache store" do
  let(:working_cache_store) { ActiveSupport::Cache::MemoryStore.new }

  after do
    # Reset to working state after each test
    Avo.instance_variable_set(:@cache_store, Avo.configuration.cache_store)
    Avo.clear_status_error
    Avo.check_cache_store_status!
  end

  describe "Avo.check_cache_store_status!" do
    describe "with a working cache store" do
      before do
        Avo.clear_status_error
        Avo.instance_variable_set(:@cache_store, working_cache_store)
      end

      it "does not set a status error" do
        Avo.check_cache_store_status!

        expect(Avo.status_error).to be_nil
      end

      it "returns true for status_ok?" do
        Avo.check_cache_store_status!

        expect(Avo.status_ok?).to be true
      end

      it "writes, reads, and deletes a test value" do
        expect(working_cache_store).to receive(:write).and_call_original
        expect(working_cache_store).to receive(:read).and_call_original
        expect(working_cache_store).to receive(:delete).and_call_original

        Avo.check_cache_store_status!
      end
    end

    describe "with a nil cache store" do
      before do
        Avo.clear_status_error
        Avo.instance_variable_set(:@cache_store, nil)
      end

      it "sets status_error with appropriate message" do
        Avo.check_cache_store_status!

        expect(Avo.status_error[:message]).to include("Avo cache store is not configured")
      end

      it "sets status_error with help text" do
        Avo.check_cache_store_status!

        expect(Avo.status_error[:help]).to be_present
      end

      it "sets status_error with documentation URL" do
        Avo.check_cache_store_status!

        expect(Avo.status_error[:doc_url]).to eq("https://docs.avohq.io/4.0/cache.html")
      end

      it "returns false for status_ok?" do
        Avo.check_cache_store_status!

        expect(Avo.status_ok?).to be false
      end
    end

    describe "with a non-operational cache store" do
      let(:broken_cache_store) do
        store = ActiveSupport::Cache::MemoryStore.new
        allow(store).to receive(:read).and_return(nil)
        store
      end

      before do
        Avo.clear_status_error
        Avo.instance_variable_set(:@cache_store, broken_cache_store)
      end

      it "sets status_error when read returns wrong value" do
        Avo.check_cache_store_status!

        expect(Avo.status_error[:message]).to include("Avo cache store is not operational")
      end

      it "returns false for status_ok?" do
        Avo.check_cache_store_status!

        expect(Avo.status_ok?).to be false
      end
    end

    describe "when cache store raises an error" do
      let(:error_cache_store) do
        store = ActiveSupport::Cache::MemoryStore.new
        allow(store).to receive(:write).and_raise(StandardError.new("Connection refused"))
        store
      end

      before do
        Avo.clear_status_error
        Avo.instance_variable_set(:@cache_store, error_cache_store)
      end

      it "sets status_error with the original error message" do
        Avo.check_cache_store_status!

        expect(Avo.status_error[:message]).to include("Connection refused")
      end

      it "includes documentation URL" do
        Avo.check_cache_store_status!

        expect(Avo.status_error[:doc_url]).to include("https://docs.avohq.io/4.0/cache.html")
      end

      it "returns false for status_ok?" do
        Avo.check_cache_store_status!

        expect(Avo.status_ok?).to be false
      end
    end
  end

  describe "Avo.status_ok?" do
    it "returns true when status_error is nil" do
      Avo.instance_variable_set(:@status_error, nil)

      expect(Avo.status_ok?).to be true
    end

    it "returns false when status_error is set" do
      Avo.set_status_error(message: "Some error")

      expect(Avo.status_ok?).to be false
    end
  end

  describe "Avo.set_status_error" do
    before { Avo.clear_status_error }

    it "sets the status error with all fields" do
      Avo.set_status_error(
        message: "Test error",
        help: "Test help",
        doc_url: "https://example.com"
      )

      expect(Avo.status_error).to eq({
        message: "Test error",
        help: "Test help",
        doc_url: "https://example.com"
      })
    end

    it "sets the status error with only message" do
      Avo.set_status_error(message: "Test error")

      expect(Avo.status_error[:message]).to eq("Test error")
      expect(Avo.status_error[:help]).to be_nil
      expect(Avo.status_error[:doc_url]).to be_nil
    end
  end

  describe "Avo.clear_status_error" do
    it "clears the status error" do
      Avo.set_status_error(message: "Test error")
      Avo.clear_status_error

      expect(Avo.status_error).to be_nil
      expect(Avo.status_ok?).to be true
    end
  end
end
