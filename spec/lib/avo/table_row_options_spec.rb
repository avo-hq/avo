require "rails_helper"

RSpec.describe Avo::TableRowOptions do
  # Minimal record/resource fakes — the merger only reads `record.to_param`,
  # `resource.class`, and treats blocks as instance_exec'd by ExecutionContext
  # so anything the block calls is a method on the fake.
  let(:record) { Struct.new(:id, :role, :to_param).new(42, "agent", "42") }

  before do
    stub_const("Avo::Resources::FakeMessage", Class.new {
      attr_reader :record
      def initialize(record)
        @record = record
      end
    })
  end

  let(:resource) { Avo::Resources::FakeMessage.new(record) }
  let(:view) { :index }

  let(:avo_attributes) do
    {
      id: "avo_resources_message_42",
      class: "table-row group z-21",
      data: {
        index: 0,
        component_name: "avo/index/table_row_component",
        resource_name: "messages",
        record_id: "42",
        controller: "item-selector table-row",
        action: "click->table-row#visitRecord keydown.enter->table-row#visitRecord"
      }
    }
  end

  def merge(user_options:, view: :index)
    described_class.merge(
      avo_attributes: avo_attributes,
      user_options: user_options,
      record: record,
      resource: resource,
      view: view
    )
  end

  describe "no user options" do
    it "returns avo_attributes unchanged when user_options is nil" do
      expect(merge(user_options: nil)).to eq(avo_attributes)
    end

    it "returns avo_attributes unchanged when user_options is an empty hash" do
      expect(merge(user_options: {})).to eq(avo_attributes)
    end
  end

  describe "class merging" do
    it "appends a String class" do
      result = merge(user_options: {class: "highlight"})
      expect(result[:class]).to eq("table-row group z-21 highlight")
    end

    it "appends an Array<String> class" do
      result = merge(user_options: {class: ["highlight", "bordered"]})
      expect(result[:class]).to eq("table-row group z-21 highlight bordered")
    end

    it "appends a Hash<String, Boolean> class with truthy keys only" do
      result = merge(user_options: {class: {"active" => true, "disabled" => false}})
      expect(result[:class]).to eq("table-row group z-21 active")
    end

    it "evaluates a per-value class block with record in scope" do
      result = merge(user_options: {class: -> { "role-#{record.role}" }})
      expect(result[:class]).to eq("table-row group z-21 role-agent")
    end

    it "leaves Avo's class unchanged when block returns nil" do
      result = merge(user_options: {class: -> {}})
      expect(result[:class]).to eq("table-row group z-21")
    end

    it "leaves Avo's class unchanged when block returns false" do
      result = merge(user_options: {class: -> { false }})
      expect(result[:class]).to eq("table-row group z-21")
    end
  end

  describe "data merging" do
    it "passes through non-reserved data keys" do
      result = merge(user_options: {data: {test_id: "row"}})
      expect(result[:data]).to include(test_id: "row")
    end

    it "preserves Avo's data attributes when user adds new ones" do
      result = merge(user_options: {data: {test_id: "row"}})
      expect(result[:data]).to include(
        index: 0,
        component_name: "avo/index/table_row_component",
        record_id: "42"
      )
    end

    it "token-concatenates data-controller, preserving Avo's tokens" do
      result = merge(user_options: {data: {controller: "my-controller"}})
      tokens = result[:data][:controller].split(/\s+/)
      expect(tokens).to include("item-selector", "table-row", "my-controller")
    end

    it "token-concatenates data-action, preserving Avo's tokens" do
      result = merge(user_options: {data: {action: "click->mything#do"}})
      expect(result[:data][:action]).to include("click->table-row#visitRecord")
      expect(result[:data][:action]).to include("click->mything#do")
    end

    it "deduplicates tokens in data-controller" do
      result = merge(user_options: {data: {controller: "table-row item-selector"}})
      tokens = result[:data][:controller].split(/\s+/)
      expect(tokens.count("table-row")).to eq(1)
      expect(tokens.count("item-selector")).to eq(1)
    end

    describe "Avo-wins on reserved keys" do
      it "drops user-provided record_id and warns" do
        expect(Avo.logger).to receive(:warn).with(/record_id/)
        result = merge(user_options: {data: {record_id: "spoof"}})
        expect(result[:data][:record_id]).to eq("42")
      end

      it "drops user-provided index" do
        allow(Avo.logger).to receive(:warn)
        result = merge(user_options: {data: {index: 999}})
        expect(result[:data][:index]).to eq(0)
      end

      it "drops user-provided component_name" do
        allow(Avo.logger).to receive(:warn)
        result = merge(user_options: {data: {component_name: "spoof"}})
        expect(result[:data][:component_name]).to eq("avo/index/table_row_component")
      end
    end

    it "evaluates a per-value data block" do
      result = merge(user_options: {data: -> { {role: record.role} }})
      expect(result[:data][:role]).to eq("agent")
    end
  end

  describe "passthrough HTML attributes" do
    it "passes through title" do
      result = merge(user_options: {title: "hello"})
      expect(result[:title]).to eq("hello")
    end

    it "passes through style" do
      result = merge(user_options: {style: "opacity: 0.5;"})
      expect(result[:style]).to eq("opacity: 0.5;")
    end

    it "passes through aria-label" do
      result = merge(user_options: {"aria-label": "Message row"})
      expect(result[:"aria-label"]).to eq("Message row")
    end

    it "evaluates per-value blocks for passthrough keys" do
      result = merge(user_options: {title: -> { "Message #{record.id}" }})
      expect(result[:title]).to eq("Message 42")
    end

    it "omits the attribute when block returns nil" do
      result = merge(user_options: {title: -> {}})
      expect(result).not_to have_key(:title)
    end
  end

  describe "top-level block form" do
    it "evaluates the top-level block" do
      block = -> { {class: record.role, title: "static"} }
      result = merge(user_options: block)
      expect(result[:class]).to eq("table-row group z-21 agent")
      expect(result[:title]).to eq("static")
    end

    it "treats top-level nil return as empty hash" do
      result = merge(user_options: -> {})
      expect(result).to eq(avo_attributes)
    end

    it "evaluates per-value blocks inside a top-level-block return" do
      block = -> { {class: -> { "deep-#{record.role}" }} }
      result = merge(user_options: block)
      expect(result[:class]).to eq("table-row group z-21 deep-agent")
    end

    it "raises when the top-level block returns a non-Hash" do
      expect {
        merge(user_options: -> { "not-a-hash" })
      }.to raise_error(ArgumentError, /Hash/)
    end
  end

  describe "view local" do
    it "exposes :index when view is :index" do
      result = merge(user_options: {class: -> { (view == :index) ? "main" : "panel" }})
      expect(result[:class]).to include("main")
    end

    it "exposes :has_many when view is :has_many" do
      result = merge(view: :has_many, user_options: {class: -> { (view == :has_many) ? "panel" : "main" }})
      expect(result[:class]).to include("panel")
    end
  end

  describe "denylist enforcement (test/dev environment)" do
    %i[id role tabindex contenteditable draggable onclick onmouseover].each do |denied|
      it "raises ArgumentError when #{denied} is set" do
        expect {
          merge(user_options: {denied => "x"})
        }.to raise_error(ArgumentError, /#{denied}/)
      end
    end

    it "raises ArgumentError when aria-selected is set" do
      expect {
        merge(user_options: {"aria-selected": true})
      }.to raise_error(ArgumentError, /aria-selected/)
    end
  end

  describe "denylist enforcement in production" do
    before { allow(Rails.env).to receive(:production?).and_return(true) }

    it "logs and falls back to avo_attributes when id is set" do
      expect(Avo.logger).to receive(:error).with(/id/)
      result = merge(user_options: {id: "spoof"})
      expect(result).to eq(avo_attributes)
    end

    it "logs and falls back when an event handler is set" do
      expect(Avo.logger).to receive(:error)
      result = merge(user_options: {onclick: "alert(1)"})
      expect(result).to eq(avo_attributes)
    end
  end

  describe "return-type contract (R11)" do
    it "raises when title block returns an Array" do
      expect {
        merge(user_options: {title: -> { ["a", "b"] }})
      }.to raise_error(ArgumentError, /title/)
    end

    it "raises when data block returns a non-Hash" do
      expect {
        merge(user_options: {data: -> { "not-a-hash" }})
      }.to raise_error(ArgumentError, /Hash/)
    end

    it "coerces a Symbol return to String for title" do
      result = merge(user_options: {title: -> { :hello }})
      expect(result[:title]).to eq("hello")
    end

    it "coerces an Integer return to String for a passthrough key" do
      result = merge(user_options: {"aria-rowindex": -> { 7 }})
      expect(result[:"aria-rowindex"]).to eq("7")
    end
  end

  describe "block error handling" do
    it "lets exceptions raised by user blocks bubble up in test environment" do
      expect {
        merge(user_options: {class: -> { record.nonexistent_method }})
      }.to raise_error(NoMethodError)
    end

    context "in production" do
      before { allow(Rails.env).to receive(:production?).and_return(true) }

      it "catches exceptions and returns avo_attributes" do
        expect(Avo.logger).to receive(:error)
        result = merge(user_options: {class: -> { record.nonexistent_method }})
        expect(result).to eq(avo_attributes)
      end
    end
  end

end
