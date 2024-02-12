# lib/formatters/flakiness.rb
require 'rspec/core/formatters/console_codes'
require 'rspec/core/formatters/documentation_formatter'

class Flakiness < RSpec::Core::Formatters::DocumentationFormatter

RSpec::Core::Formatters.register self, :example_group_started, :example_group_finished,:example_passed, :example_pending, :example_failed
  def example_passed(notification)
    return super unless notification.example.metadata[:flaky]
    output.puts flaky_output(notification.example)
  end

  def dump_summary(notification)
    super
    flaky_examples = notification.examples.select do |example|
      flaky? example
    end

    if flaky_examples.size > 0
      output.puts "\nFlaky Examples:\n\n"
      flaky_examples.each do |example|
        output.puts "#{flaky_with_location example}\n"
      end
    end
  end

private
  def flaky?(example)
    example.metadata[:flaky] && example.execution_result.status == :passed
  end

  def flaky_with_location(example)
    location         = paint example.location, :yellow
    full_description = paint example.full_description, :cyan
    "#{location}: #{full_description}"
  end

  def flaky_output(example)
    paint "#{current_indentation}
          #{example.description.strip}",:yellow
  end

  def paint(string, color)
    RSpec::Core::Formatters::ConsoleCodes.wrap(string, color)
  end
end
