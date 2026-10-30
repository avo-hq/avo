require "rails_helper"

# Hosts set `config.persistence` as a whole hash, so a key they leave out must still count as on while the
# driver is on, and nothing persists without the driver whatever the keys say.
RSpec.describe "Avo.configuration.persistence" do
  around do |example|
    original = Avo.configuration.persistence
    example.run
    Avo.configuration.persistence = original
  end

  it "persists nothing without a driver" do
    Avo.configuration.persistence = {driver: nil, sorting: true}

    expect(Avo.configuration.persist?(:sorting)).to be false
  end

  it "persists every kind of state the host did not turn off" do
    Avo.configuration.persistence = {driver: :session, sorting: false}

    expect(Avo.configuration.persist?(:sorting)).to be false
    expect(Avo.configuration.persist?(:pagination)).to be true
    expect(Avo.configuration.persist?(:filters)).to be true
    expect(Avo.configuration.persist?(:selection)).to be true
  end

  it "resolves a proc once per lookup" do
    Avo.configuration.persistence = -> { {driver: :session, selection: false} }

    expect(Avo.configuration.persist?(:selection)).to be false
    expect(Avo.configuration.persist?(:filters)).to be true
  end
end
