require "rails_helper"

# Unit 2 — provider interface, six core seams, lock DSL, option enumeration,
# cache_hash extension, and error degradation.
RSpec.describe Avo::DynamicConfigProvider do
  # A configurable stub provider. Every answer defaults to "no change" so an
  # instance only affects the seam a given example exercises.
  stub_provider_class = Class.new(Avo::DynamicConfigProvider) do
    attr_accessor :options_by_ref, :items_block, :attachables_by_kind,
      :config_values, :fingerprints, :entity_options_proc

    def initialize
      @options_by_ref = {}
      @items_block = nil
      @attachables_by_kind = {}
      @config_values = {}
      @fingerprints = {}
      @entity_options_proc = nil
    end

    def installed? = true

    def entity_options_for(entity_ref)
      return @entity_options_proc.call(entity_ref) if @entity_options_proc

      @options_by_ref[entity_ref] || {}
    end

    def items_for(resource_instance)
      @items_block&.call(resource_instance)
    end

    def attachables_for(resource_instance, kind)
      @attachables_by_kind[kind] || []
    end

    def config_value(key, file_value)
      @config_values.key?(key) ? @config_values[key] : Avo::DynamicConfigProvider::NO_CHANGE
    end

    def cache_fingerprint(resource_class)
      @fingerprints[resource_class]
    end
  end

  let(:stub_provider) { stub_provider_class.new }

  def with_provider(provider)
    Avo.register_dynamic_config_provider(provider)
    yield
  ensure
    Avo.reset_dynamic_config_provider
  end

  describe "registration + guard predicate" do
    it "defaults to the null provider and reports not-installed" do
      expect(Avo.dynamic_config_provider).to be_a(Avo::DynamicConfigProvider)
      expect(Avo.dynamic_config_provider_installed?).to be(false)
    end

    it "flips the guard when a real provider registers, and resets back" do
      with_provider(stub_provider) do
        expect(Avo.dynamic_config_provider_installed?).to be(true)
        expect(Avo.dynamic_config_provider).to be(stub_provider)
      end

      expect(Avo.dynamic_config_provider_installed?).to be(false)
    end

    it "null protocol methods answer no-change" do
      null = described_class.new

      expect(null.entity_options_for(Object)).to eq({})
      expect(null.items_for(Object.new)).to be_nil
      expect(null.attachables_for(Object.new, :action)).to eq([])
      expect(null.config_value(:app_name, "file")).to be(described_class::NO_CHANGE)
      expect(null.locked?(:anything)).to be(false)
      expect(null.cache_fingerprint(Object)).to be_nil
    end
  end

  describe "instance option seam" do
    it "overrides one option on the instance without touching class state" do
      stub_provider.options_by_ref[Avo::Resources::Post] = {title: :overridden_title}

      with_provider(stub_provider) do
        instance = Avo::Resources::Post.new(view: Avo::ViewInquirer.new("index"))

        expect(instance.title).to eq(:overridden_title)
        # Class attribute is untouched — asserted here and from another thread.
        expect(Avo::Resources::Post.title).to eq(:name)
        expect(Thread.new { Avo::Resources::Post.title }.value).to eq(:name)
      end
    end

    it "carries the override across .dup and bare .new(record:)" do
      user = User.create!(first_name: "Grace", last_name: "Hopper", email: "grace+ovr@example.com", password: "password")
      stub_provider.options_by_ref[Avo::Resources::User] = {record_selector: false}

      with_provider(stub_provider) do
        bare = Avo::Resources::User.new(record: user)
        expect(bare.record_selector).to be(false)

        dup = bare.dup
        expect(dup.record_selector).to be(false)
      end
    ensure
      user&.destroy
    end

    it "does not bleed between two concurrent requests (instance boundary)" do
      stub_provider.entity_options_proc = lambda do |ref|
        (ref == Avo::Resources::Post && Thread.current[:overlay_title]) ? {title: Thread.current[:overlay_title]} : {}
      end

      with_provider(stub_provider) do
        results = 2.times.map do |i|
          Thread.new do
            Thread.current[:overlay_title] = :"title_#{i}"
            Avo::Resources::Post.new(view: Avo::ViewInquirer.new("index")).title
          end
        end.map(&:value)

        expect(results).to contain_exactly(:title_0, :title_1)
        expect(Avo::Resources::Post.title).to eq(:name)
      end
    end
  end

  describe "detect_fields items seam" do
    it "adds, removes, and reorders fields on the per-instance holder" do
      stub_provider.items_block = lambda do |resource|
        holder = resource.items_holder
        holder.field(:overlay_added, as: :text)       # add
        holder.items.reject! { |item| item.try(:id) == :id } # remove the id field
        holder.items.reverse!                          # reorder
      end

      with_provider(stub_provider) do
        resource = Avo::Resources::User.new(view: Avo::ViewInquirer.new("index"))
        resource.detect_fields

        ids = resource.items.map { |item| item.try(:id) }
        expect(ids).to include(:overlay_added)
        expect(ids).not_to include(:id)
      end
    end
  end

  describe "entity-bag seam" do
    overlay_action = Class.new(Avo::BaseAction)

    it "injects an action definition into the per-instance bag" do
      stub_provider.attachables_by_kind[:action] = [{class: overlay_action}]

      with_provider(stub_provider) do
        resource = Avo::Resources::Post.new(view: Avo::ViewInquirer.new("index"))
        injected = resource.get_actions.map { |entry| entry[:class] }

        expect(injected).to include(overlay_action)
      end
    end
  end

  describe "Configuration read-through seam" do
    it "overrides a scalar config key" do
      stub_provider.config_values[:app_name] = "Overlay App"
      stub_provider.config_values[:per_page] = 99

      with_provider(stub_provider) do
        expect(Avo.configuration.app_name).to eq("Overlay App")
        expect(Avo.configuration.per_page).to eq(99)
      end
    end

    it "does not serve a stale appearance memo for an overlay override" do
      # Prime the file memo first.
      file_appearance = Avo.configuration.appearance
      override = Avo::Configuration::Appearance.new
      stub_provider.config_values[:appearance] = override

      with_provider(stub_provider) do
        expect(Avo.configuration.appearance).to be(override)
      end

      # Falls back to the memoized file value once the provider is gone.
      expect(Avo.configuration.appearance).to be(file_appearance)
    end
  end

  describe "class-level read wrappers (class-consumed options)" do
    it "overrides index_query through query_scope" do
      stub_provider.options_by_ref[Avo::Resources::User] = {index_query: -> { query.where(active: true) }}

      with_provider(stub_provider) do
        sql = Avo::Resources::User.query_scope.to_sql
        expect(sql).to match(/active/)
      end
    end

    it "overrides the search config through fetch_search / search_query" do
      stub_provider.options_by_ref[Avo::Resources::Post] = {search: {query: -> { query }, help: "overlay help"}}

      with_provider(stub_provider) do
        expect(Avo::Resources::Post.fetch_search(:help)).to eq("overlay help")
      end
    end
  end

  describe "navigation / discovery seam" do
    it "hides a resource and relabels/re-icons another" do
      Avo.init
      stub_provider.options_by_ref[Avo::Resources::User] = {visible_on_sidebar: false}
      stub_provider.options_by_ref[Avo::Resources::Post] = {navigation_label: "Articles", icon: "custom-icon"}

      with_provider(stub_provider) do
        navigable = Avo.resource_manager.resources_for_navigation

        expect(navigable).not_to include(Avo::Resources::User)
        expect(Avo::Resources::Post.navigation_label).to eq("Articles")
        expect(Avo::Resources::Post.icon).to eq("custom-icon")
      end

      # File values restored once the provider is gone.
      expect(Avo::Resources::Post.icon).to eq(Avo::Resources::Post.send(:_file_icon))
    end
  end

  describe "lock DSL (R28)" do
    it "ignores an overlay override on a per-resource locked option, still queryable" do
      locked_resource = Class.new(Avo::Resources::Post) do
        locked_options :title
      end
      stub_provider.options_by_ref[locked_resource] = {title: :hacked}

      with_provider(stub_provider) do
        instance = locked_resource.new(view: Avo::ViewInquirer.new("index"))
        expect(instance.title).to eq(:name) # inherited file value, override ignored
      end

      expect(locked_resource.dynamic_config_locked_option?(:title)).to be(true)
    end

    it "locks the default-locked resource option (authorization_policy)" do
      expect(Avo::Resources::User.dynamic_config_locked_option?(:authorization_policy)).to be(true)
    end

    it "locks default config keys and app-declared config keys" do
      expect(Avo::DynamicConfigProvider.config_key_locked?(:license_key)).to be(true)
      expect(Avo::DynamicConfigProvider.config_key_locked?(:current_user_method)).to be(true)

      Avo.configuration.lock_config_keys(:currency)
      stub_provider.config_values[:currency] = "OVERLAY"

      with_provider(stub_provider) do
        expect(Avo.configuration.currency).to eq("USD") # locked → file value
      end
    ensure
      Avo.configuration.locked_config_keys.delete(:currency)
    end
  end

  describe "cache_hash extension" do
    it "mixes in the provider fingerprint and busts when it changes" do
      user = User.create!(first_name: "Ada", last_name: "L", email: "ada+cache@example.com", password: "password")
      resource = Avo::Resources::User.new(record: user, view: Avo::ViewInquirer.new("index"))

      baseline = resource.cache_hash(nil)

      stub_provider.fingerprints[Avo::Resources::User] = "fp-1"
      with_provider(stub_provider) do
        with_fp1 = resource.cache_hash(nil)
        expect(with_fp1).to include("fp-1")
        expect(with_fp1).not_to eq(baseline)

        stub_provider.fingerprints[Avo::Resources::User] = "fp-2"
        expect(resource.cache_hash(nil)).to include("fp-2")
      end

      # No provider → today's key is unchanged (no extra element).
      expect(resource.cache_hash(nil)).to eq(baseline)
    ensure
      user&.destroy
    end
  end

  describe "error degradation (R15 core half)" do
    it "serves the file value and logs when the provider raises in a seam" do
      raising = stub_provider_class.new
      raising.define_singleton_method(:config_value) { |_key, _file| raise "boom" }

      expect(Avo.logger).to receive(:error).at_least(:once)

      with_provider(raising) do
        expect { @app_name = Avo.configuration.app_name }.not_to raise_error
        expect(@app_name).to be_a(String)
      end
    end
  end

  describe "enumerable option registry + completeness (R8)" do
    let(:declared) { Avo::Resources::Base.own_dynamic_config_option_attributes }
    let(:classified) { Avo::Resources::Base::DYNAMIC_CONFIG_OPTIONS }
    let(:excluded) { Avo::Resources::Base::DYNAMIC_CONFIG_EXCLUDED_OPTIONS }

    it "exposes the overridable option names for Unit 6" do
      expect(Avo::Resources::Base.dynamic_config_options).to eq(classified)
    end

    it "every declared option class_attribute is classified or excluded" do
      expect(declared.sort).to eq((classified + excluded).sort)
    end

    it "fails (detects drift) when a new unclassified option is added" do
      fake_resource = Class.new(Avo::Resources::Base) do
        class_attribute :totally_new_unclassified_option
      end

      unclassified = fake_resource.own_dynamic_config_option_attributes - classified - excluded

      expect(unclassified).to include(:totally_new_unclassified_option)
    end
  end
end
