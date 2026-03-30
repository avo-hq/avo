require "rails_helper"

RSpec.describe Avo::DeveloperWarningComponent, type: :component do
  let(:message) { "Hello <a href='https://example.com'>link</a>" }

  it "renders in test environment" do
    result = render_inline(described_class.new(message))

    expect(result).to have_css('[data-tippy="tooltip"]')
    expect(result).to have_text("Hello link")
  end

  it "renders in development environment" do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))

    result = render_inline(described_class.new(message))

    expect(result).to have_css('[data-tippy="tooltip"]')
    expect(result).to have_text("Hello link")
  end

  it "does not render in production environment" do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))

    result = render_inline(described_class.new(message))

    expect(result.to_html.strip).to eq("")
  end
end
