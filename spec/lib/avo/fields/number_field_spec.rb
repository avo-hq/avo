require "rails_helper"

RSpec.describe Avo::Fields::NumberField, type: :model do
  let(:view_context) do
    Class.new do
      include ActionView::Helpers::NumberHelper

      def main_app
      end

      def avo
      end
    end.new
  end

  before do
    allow(Avo::Current).to receive(:view_context).and_return(view_context)
  end

  def build_field(value, view: :index, **args)
    record = Struct.new(:amount).new(value)

    described_class.new(:amount, **args).hydrate(record:, view:)
  end

  describe "format" do
    {
      delimited: [8_419_600, "8,419,600"],
      currency: [1234, "USD1,234.00"],
      percentage: [12.5, "12.5%"],
      human: [8_419_600, "8.42 Million"]
    }.each do |format, (value, expected)|
      it "formats a number as #{format}" do
        expect(build_field(value, format:).value).to eq expected
      end
    end

    it "formats only display views" do
      field = build_field(8_419_600, view: :edit, format: :delimited)

      expect(field.value).to eq 8_419_600
    end

    it "uses the current locale" do
      I18n.backend.store_translations(:de, number: {format: {delimiter: ".", separator: ","}})

      value = I18n.with_locale(:de) do
        build_field(8_419_600, format: :delimited).value
      end

      expect(value).to eq "8.419.600"
    end

    {
      format_index_using: :index,
      format_show_using: :show,
      format_display_using: :index,
      format_using: :index
    }.each do |formatter, view|
      it "is overridden by #{formatter}" do
        field = build_field(
          8_419_600,
          view:,
          format: :delimited,
          **{formatter => -> { "Population: #{value}" }}
        )

        expect(field.value).to eq "Population: 8419600"
      end
    end

    it "rejects unknown formats" do
      expect { build_field(12, format: :scientific) }
        .to raise_error(ArgumentError, /Invalid number format/)
    end
  end

  describe "#table_header_class" do
    it "end-aligns formatted numbers" do
      expect(build_field(12, format: :delimited).table_header_class.split).to include("text-end")
    end

    it "keeps bare numbers start-aligned" do
      expect(build_field(2026).table_header_class.split).not_to include("text-end")
    end
  end
end
