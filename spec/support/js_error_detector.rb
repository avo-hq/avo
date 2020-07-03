RSpec.configure do |config|
  config.after(:each, type: :system, skip_js_error_detect: nil) do
    errors = page.driver.browser.manage.logs.get(:browser)
    if errors.present?
      aggregate_failures 'javascript errors' do
        errors.each do |error|
          expect(error.level).not_to eq('SEVERE'), error.message
          next unless error.level == 'WARNING'
          STDERR.puts 'WARN: javascript warning'
          STDERR.puts error.message
        end
      end
    end
  end
end
