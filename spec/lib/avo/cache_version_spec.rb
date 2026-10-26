require "rails_helper"

# Fragments rendered by ViewComponents carry no template digest, so nothing in
# a cached index row's key would change on `bundle update avo` unless the key
# names the versions itself. `Avo.cache_version` is that name.
RSpec.describe "Avo.cache_version" do
  after { Avo.instance_variable_set(:@cache_version, nil) }

  def digest_of(*parts)
    Digest::MD5.hexdigest(parts.sort.join("|"))
  end

  it "digests the Avo version and every registered plugin's name and version" do
    Avo.instance_variable_set(:@cache_version, nil)

    expected = digest_of(Avo::VERSION, *Avo.plugin_manager.plugins.map(&:to_s))

    expect(Avo.cache_version).to eq expected
    expect(Avo.plugin_manager.plugins).not_to be_empty
  end

  it "changes when a plugin's version changes" do
    Avo.instance_variable_set(:@cache_version, nil)
    before_upgrade = Avo.cache_version

    plugin = Avo.plugin_manager.plugins.first
    allow(plugin).to receive(:version).and_return("999.0.0")
    Avo.instance_variable_set(:@cache_version, nil)

    expect(Avo.cache_version).not_to eq before_upgrade
  end

  it "changes when Avo itself is upgraded" do
    Avo.instance_variable_set(:@cache_version, nil)
    before_upgrade = Avo.cache_version

    stub_const("Avo::VERSION", "999.0.0")
    Avo.instance_variable_set(:@cache_version, nil)

    expect(Avo.cache_version).not_to eq before_upgrade
  end

  it "is computed once per process" do
    Avo.instance_variable_set(:@cache_version, nil)
    allow(Digest::MD5).to receive(:hexdigest).and_call_original

    2.times { Avo.cache_version }

    expect(Digest::MD5).to have_received(:hexdigest).once
  end
end
