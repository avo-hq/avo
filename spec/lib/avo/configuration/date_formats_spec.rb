require "rails_helper"

# `config.date_format`, `config.date_time_format`, and `config.time_format` are the
# formats date, date_time, and time fields display with when they don't pass `format:`.
RSpec.describe "Avo.configuration date formats" do
  around do |example|
    originals = %i[date_format date_time_format time_format].index_with { |option| Avo.configuration.public_send(option) }
    example.run
    originals.each { |option, value| Avo.configuration.public_send(:"#{option}=", value) }
  end

  {
    date_format: [Avo::Fields::DateField, "yyyy-LL-dd"],
    date_time_format: [Avo::Fields::DateTimeField, "yyyy-LL-dd TT"],
    time_format: [Avo::Fields::TimeField, "TT"]
  }.each do |option, (field_class, default)|
    describe option.to_s do
      it "defaults to #{default.inspect}" do
        expect(Avo::Configuration.new.public_send(option)).to eq default
        expect(field_class.new(:starts_at).format).to eq default
      end

      it "sets the format a #{field_class.name.demodulize} displays with" do
        Avo.configuration.public_send(:"#{option}=", "dd.LL.yyyy")

        expect(field_class.new(:starts_at).format).to eq "dd.LL.yyyy"
      end

      it "gives way to the field's own format" do
        Avo.configuration.public_send(:"#{option}=", "dd.LL.yyyy")

        expect(field_class.new(:starts_at, format: "LLL d").format).to eq "LLL d"
      end
    end
  end

  it "keeps each field type on its own option" do
    Avo.configuration.date_format = "dd.LL.yyyy"
    Avo.configuration.date_time_format = "dd.LL.yyyy HH:mm"
    Avo.configuration.time_format = "HH:mm"

    expect(Avo::Fields::DateField.new(:starts_at).format).to eq "dd.LL.yyyy"
    expect(Avo::Fields::DateTimeField.new(:starts_at).format).to eq "dd.LL.yyyy HH:mm"
    expect(Avo::Fields::TimeField.new(:starts_at).format).to eq "HH:mm"
  end
end
