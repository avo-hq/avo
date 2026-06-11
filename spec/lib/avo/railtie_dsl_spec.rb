require "rails_helper"

RSpec.describe "Avo::RailtieDSL load order" do
  it "is available via standalone require without full avo boot" do
    expect(Avo::RailtieDSL).to be_a(Module)
    expect(Avo::RailtieDSL.instance_methods).to include(:avo_railtie)
  end
end

RSpec.describe Avo::RailtieDSL do
  before do
    stub_const("Avo::RailtieDSLSpec", Module.new)

    stub_const("Avo::RailtieDSLSpec::RailtieHandler", Class.new do
      def self.handle
        -> {
          initializer "avo-railtie-dsl-spec.init" do
          end
        }
      end
    end)

    stub_const("Avo::RailtieDSLSpec::Railtie", Class.new(Rails::Railtie) do
      extend Avo::RailtieDSL
      avo_railtie
    end)
  end

  let(:railtie) { Avo::RailtieDSLSpec::Railtie }

  it "registers initializers from the handler proc" do
    expect(railtie.initializers.map(&:name)).to include("avo-railtie-dsl-spec.init")
  end

  it "accepts an explicit handler class" do
    stub_const("Avo::RailtieDSLSpec::CustomHandler", Class.new do
      def self.handle
        -> {
          initializer "avo-railtie-dsl-spec.custom" do
          end
        }
      end
    end)

    railtie_class = Class.new(Rails::Railtie) do
      def self.name
        "Avo::RailtieDSLSpec::CustomRailtie"
      end

      extend Avo::RailtieDSL
      avo_railtie Avo::RailtieDSLSpec::CustomHandler
    end

    expect(railtie_class.initializers.map(&:name)).to include("avo-railtie-dsl-spec.custom")
  end
end
