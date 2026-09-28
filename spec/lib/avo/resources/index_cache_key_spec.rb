require "rails_helper"

# The key an index row is cached under is `cache_hash` (the record's part) plus
# `cache_context` (the request's part: who is looking, in which locale and
# tenant). They compose so an app's `cache_hash` override keeps working and
# cannot drop the viewer from the key — the leak in avo-hq/avo#1507.
#
# Everything here stubs the real Post resource rather than subclassing it:
# `Avo.resource_manager` discovers resources through `Base.descendants`, so an
# anonymous subclass created here would show up in the sidebar of every system
# spec that runs after this file, with no route to its name.
RSpec.describe "Resource#index_cache_key" do
  let(:user) { create :user }
  let(:post) { create :post }
  let(:parent) { create :user }

  let(:resource) { Avo::Resources::Post.new(record: post, view: :index) }

  around do |example|
    Avo::Current.set(user: user, tenant_id: "acme") do
      I18n.with_locale(:en) { example.run }
    end
  end

  # An app overriding `cache_hash` the way the docs show, unaware of any
  # per-viewer dimension.
  before do
    allow(resource).to receive(:cache_hash) { |parent_record| [post, "custom", parent_record].compact }
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
    allow(resource).to receive(:cache_context).and_return([post.class.name, "role"])

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
    let(:klass) { Avo::Resources::Post }

    # The class-level memo must not survive an example that stubbed its inputs.
    around do |example|
      klass.instance_variable_set(:@file_hash, nil)
      example.run
    ensure
      klass.instance_variable_set(:@file_hash, nil)
    end

    it "is the class-level digest of the resource and policy files" do
      expect(klass.new(record: post).file_hash).to eq klass.file_hash
      expect(klass.file_hash).to match(/\A\h{32}\z/)
    end

    it "is computed once per class when the app is packed" do
      stub_const("Avo::PACKED", true)
      allow(klass).to receive(:compute_file_hash).and_call_original

      2.times { klass.file_hash }

      expect(klass).to have_received(:compute_file_hash).once
    end

    it "changes when Avo or a plugin is upgraded, without either file changing" do
      allow(Avo).to receive(:cache_version).and_return("avo-4.2.8")
      before_upgrade = klass.compute_file_hash
      allow(Avo).to receive(:cache_version).and_return("avo-4.2.9")

      expect(klass.compute_file_hash).not_to eq before_upgrade
    end

    it "is recomputed on every call while developing, when the files change" do
      stub_const("Avo::PACKED", false)
      allow(klass).to receive(:compute_file_hash).and_call_original

      2.times { klass.file_hash }

      expect(klass).to have_received(:compute_file_hash).twice
    end
  end
end
