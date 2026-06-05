require "rails_helper"

RSpec.describe Avo::EngineDSL do
  before do
    stub_const("Avo::EngineDSLSpec", Module.new)

    stub_const("Avo::EngineDSLSpec::EngineHandler", Class.new do
      def self.handle
        -> {
          isolate_namespace Avo::EngineDSLSpec

          initializer "avo-engine-dsl-spec.init" do
          end
        }
      end
    end)

    stub_const("Avo::EngineDSLSpec::Engine", Class.new(Rails::Engine) do
      extend Avo::EngineDSL
      avo_engine
    end)
  end

  let(:engine) { Avo::EngineDSLSpec::Engine }

  it "registers initializers from the handler proc" do
    expect(engine.initializers.map(&:name)).to include("avo-engine-dsl-spec.init")
  end

  it "isolates the engine namespace" do
    expect(engine).to be_isolated
    expect(engine.isolated_namespace).to eq(Avo::EngineDSLSpec)
  end

  it "accepts an explicit handler class" do
    stub_const("Avo::EngineDSLSpec::CustomHandler", Class.new do
      def self.handle
        -> {
          initializer "avo-engine-dsl-spec.custom" do
          end
        }
      end
    end)

    engine_class = Class.new(Rails::Engine) do
      def self.name
        "Avo::EngineDSLSpec::CustomEngine"
      end

      extend Avo::EngineDSL
      avo_engine Avo::EngineDSLSpec::CustomHandler
    end

    expect(engine_class.initializers.map(&:name)).to include("avo-engine-dsl-spec.custom")
  end
end
