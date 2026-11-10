# frozen_string_literal: true

require "rails_helper"

# A panel in Romanian or Norwegian Nynorsk raised on every list longer than one page: Avo shipped its own Pagy
# dictionaries for those two, in the shape Pagy read before 43, and they shadowed the ones Pagy now ships.
RSpec.describe "Pagy dictionaries" do
  let(:languages) do
    Dir[Avo::Engine.root.join("lib", "generators", "avo", "templates", "locales", "avo.*.yml")]
      .map { |file| File.basename(file, ".yml").delete_prefix("avo.") }
  end

  after { Pagy::I18n.locale = nil }

  it "names the pagination's links in every language Avo ships" do
    languages.each do |language|
      Pagy::I18n.locale = language

      expect { Pagy::I18n.translate("pagy.aria_label.nav", count: 2) }.not_to raise_error, "#{language} raised"
    end
  end
end
