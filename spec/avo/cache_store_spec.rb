require "rails_helper"

RSpec.describe "Avo.ensure_cache_store_operational!" do
  let(:working_cache_store) { ActiveSupport::Cache::MemoryStore.new }

  describe "with a working cache store" do
    before do
      allow(Avo).to receive(:cache_store).and_return(working_cache_store)
      Avo.instance_variable_set(:@cache_store, working_cache_store)
    end

    it "does not raise an error" do
      expect { Avo.ensure_cache_store_operational! }.not_to raise_error
    end

    it "writes and reads a test value" do
      expect(working_cache_store).to receive(:write).and_call_original
      expect(working_cache_store).to receive(:read).and_call_original
      expect(working_cache_store).to receive(:delete).and_call_original

      Avo.ensure_cache_store_operational!
    end
  end

  describe "with a nil cache store" do
    before do
      Avo.instance_variable_set(:@cache_store, nil)
    end

    after do
      Avo.instance_variable_set(:@cache_store, Avo.configuration.cache_store)
    end

    it "raises CacheStoreNotOperationalError" do
      expect { Avo.ensure_cache_store_operational! }.to raise_error(
        Avo::CacheStoreNotOperationalError,
        "Avo cache store is not configured"
      )
    end
  end

  describe "with a non-operational cache store" do
    let(:broken_cache_store) do
      store = ActiveSupport::Cache::MemoryStore.new
      allow(store).to receive(:read).and_return(nil)
      store
    end

    before do
      Avo.instance_variable_set(:@cache_store, broken_cache_store)
    end

    after do
      Avo.instance_variable_set(:@cache_store, Avo.configuration.cache_store)
    end

    it "raises CacheStoreNotOperationalError when read returns wrong value" do
      expect { Avo.ensure_cache_store_operational! }.to raise_error(
        Avo::CacheStoreNotOperationalError,
        /Avo cache store is not operational/
      )
    end
  end

  describe "when cache store raises an error" do
    let(:error_cache_store) do
      store = ActiveSupport::Cache::MemoryStore.new
      allow(store).to receive(:write).and_raise(StandardError.new("Connection refused"))
      store
    end

    before do
      Avo.instance_variable_set(:@cache_store, error_cache_store)
    end

    after do
      Avo.instance_variable_set(:@cache_store, Avo.configuration.cache_store)
    end

    it "raises CacheStoreNotOperationalError with the original error message" do
      expect { Avo.ensure_cache_store_operational! }.to raise_error(
        Avo::CacheStoreNotOperationalError,
        /Connection refused/
      )
    end

    it "includes documentation link in error message" do
      expect { Avo.ensure_cache_store_operational! }.to raise_error(
        Avo::CacheStoreNotOperationalError,
        /https:\/\/docs\.avohq\.io\/4\.0\/cache\.html/
      )
    end
  end
end
