require "rubocop"
require "rubocop/rspec/support"
require "rubo_cop/cop/custom/heroicons_svg_check"

RSpec.describe RuboCop::Cop::Custom::HeroiconsSvgCheck, :config do
  include RuboCop::RSpec::ExpectOffense

  subject(:cop) { described_class.new(config) }

  it "registers an offense when svg does not use heroicons prefix" do
    expect_offense(<<~RUBY)
      svg("edit")
      ^^^^^^^^^^^ SVG declaration does not adhere to naming convention
    RUBY

    expect_offense(<<~RUBY)
      svg('edit')
      ^^^^^^^^^^^ SVG declaration does not adhere to naming convention
    RUBY
  end

  it "does not register an offense when svg uses heroicons prefix" do
    expect_no_offenses(<<~RUBY)
      svg("heroicons/outline/edit")
    RUBY

    expect_no_offenses(<<~RUBY)
      svg('avo/three-dots')
    RUBY
  end
end
