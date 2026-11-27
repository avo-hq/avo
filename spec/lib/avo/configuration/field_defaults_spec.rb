require "rails_helper"

# `config.field_defaults` holds the options every field of a type starts with,
# keyed by the field type. A field's own options win over them.
RSpec.describe "Avo.configuration field defaults" do
  around do |example|
    original = Avo.configuration.field_defaults
    example.run
    Avo.configuration.field_defaults = original
  end

  def parse_field(id = :name, **args, &block)
    Avo::Dsl::FieldParser.new(id: id, **args, &block).parse.instance
  end

  it "defaults to no field defaults" do
    expect(Avo::Configuration.new.field_defaults).to eq({})
    expect(parse_field(as: :text).help).to be_nil
  end

  it "gives every field of the type its options" do
    Avo.configuration.field_defaults = {
      text: {help: "Shown under every text field", sortable: true},
      belongs_to: {link_to_record: true}
    }

    expect(parse_field(as: :text)).to have_attributes(help: "Shown under every text field", sortable: true)
    expect(parse_field(:user, as: :belongs_to).link_to_record).to be(true)
  end

  it "leaves fields of other types alone" do
    Avo.configuration.field_defaults = {text: {help: "Shown under every text field"}}

    expect(parse_field(as: :textarea).help).to be_nil
    expect(parse_field(as: :number).help).to be_nil
  end

  it "gives way to the field's own options, false and nil included" do
    Avo.configuration.field_defaults = {text: {help: "Shown under every text field", sortable: true, label_help: "Under the label"}}

    field = parse_field(as: :text, help: "Just this one", sortable: false, label_help: nil)

    expect(field).to have_attributes(help: "Just this one", sortable: false, label_help: nil)
  end

  it "applies the text defaults to fields declared without `as:`" do
    Avo.configuration.field_defaults = {text: {help: "Shown under every text field"}}

    expect(parse_field.help).to eq "Shown under every text field"
  end

  it "applies the defaults to fields declared with a class" do
    Avo.configuration.field_defaults = {text: {help: "Shown under every text field"}}

    expect(parse_field(as: Avo::Fields::TextField).help).to eq "Shown under every text field"
  end

  it "keeps computed fields computed" do
    Avo.configuration.field_defaults = {text: {help: "Shown under every text field"}}

    field = parse_field(as: :text) { "computed" }

    expect(field).to have_attributes(computed: true, help: "Shown under every text field")
  end

  it "accepts string keys" do
    Avo.configuration.field_defaults = {"text" => {"help" => "Shown under every text field"}}

    expect(Avo.configuration.field_defaults).to eq(text: {help: "Shown under every text field"})
    expect(parse_field(as: :text).help).to eq "Shown under every text field"
  end

  it "resets to no field defaults when set to nil" do
    Avo.configuration.field_defaults = {text: {help: "Shown under every text field"}}
    Avo.configuration.field_defaults = nil

    expect(Avo.configuration.field_defaults).to eq({})
  end

  it "raises when the value is not a hash" do
    expect { Avo.configuration.field_defaults = [:text] }
      .to raise_error(ArgumentError, /Must be a hash keyed by field type/)
  end

  it "raises when a field type's options are not a hash" do
    expect { Avo.configuration.field_defaults = {text: {sortable: true}, belongs_to: true} }
      .to raise_error(ArgumentError, /Invalid field defaults for \[:belongs_to\]/)
  end
end
