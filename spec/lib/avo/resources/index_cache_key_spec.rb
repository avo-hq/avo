require "rails_helper"

# The key an index row is cached under is `cache_hash` (the record's part) plus
# `cache_context` (the request's part: who is looking, in which locale and
# tenant). They compose so an app's `cache_hash` override keeps working and
# cannot drop the viewer from the key — the leak in avo-hq/avo#1507.
RSpec.describe "Resource#index_cache_key" do
  let(:user) { create :user }
  let(:post) { create :post }
  let(:parent) { create :user }

  # A resource that overrides `cache_hash` the way the docs show, unaware of
  # any per-viewer dimension.
  let(:resource_class) do
    Class.new(Avo::Resources::Post) do
      def self.name = "Avo::Resources::Post"

      def cache_hash(parent_record)
        [record, "custom", parent_record].compact
      end
    end
  end

  let(:resource) { resource_class.new(record: post, view: :index) }

  around do |example|
    Avo::Current.set(user: user, tenant_id: "acme") do
      I18n.with_locale(:en) { example.run }
    end
  end

  it "appends the default context — user record, locale, tenant — after the overridden cache_hash" do
    expect(resource.index_cache_key(nil)).to eq [post, "custom", user, :en, "acme"]
  end

  it "keeps the parent record in the cache_hash part" do
    expect(resource.index_cache_key(parent)).to eq [post, "custom", parent, user, :en, "acme"]
  end

  it "resolves config.index_cache_context through the execution context" do
    original = Avo.configuration.index_cache_context
    Avo.configuration.index_cache_context = -> { [current_user.id, params[:q]] }

    expect(resource.index_cache_key(nil)).to eq [post, "custom", user.id, nil]
  ensure
    Avo.configuration.index_cache_context = original
  end

  it "reuses a context already resolved for the request when one is passed in" do
    expect(resource.index_cache_key(nil, cache_context: [:shared])).to eq [post, "custom", :shared]
  end

  it "lets a resource override cache_context on its own" do
    resource_class.define_method(:cache_context) { [record.class.name, "role"] }

    expect(resource.index_cache_key(nil)).to eq [post, "custom", "Post", "role"]
  end

  it "expands the user record to a versioned cache key so a role edit busts the row" do
    expanded = ActiveSupport::Cache.expand_cache_key(resource.index_cache_key(nil))

    expect(expanded).to include(user.cache_key_with_version)
    expect(expanded).to include(post.cache_key_with_version)
  end

  it "is a cache-friendly key when nobody is signed in" do
    Avo::Current.user = nil

    expect { ActiveSupport::Cache.expand_cache_key(resource.index_cache_key(nil)) }.not_to raise_error
  end

  describe "file_hash" do
    it "is the class-level digest of the resource and policy files" do
      expect(Avo::Resources::Post.new(record: post).file_hash).to eq Avo::Resources::Post.file_hash
      expect(Avo::Resources::Post.file_hash).to match(/\A\h{32}\z/)
    end

    it "is computed once per class when the app is packed" do
      stub_const("Avo::PACKED", true)

      klass = Class.new(Avo::Resources::Post) { def self.name = "Avo::Resources::Post" }
      allow(klass).to receive(:compute_file_hash).and_call_original

      2.times { klass.file_hash }

      expect(klass).to have_received(:compute_file_hash).once
    end

    it "is recomputed on every call while developing, when the files change" do
      stub_const("Avo::PACKED", false)

      klass = Class.new(Avo::Resources::Post) { def self.name = "Avo::Resources::Post" }
      allow(klass).to receive(:compute_file_hash).and_call_original

      2.times { klass.file_hash }

      expect(klass).to have_received(:compute_file_hash).twice
    end
  end
end
