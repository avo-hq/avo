require "timeout"

def wait_for_ajax_loading(time = Capybara.default_max_wait_time)
  Timeout.timeout(time) { sleep(0.01) until page.find("body")[:class].include?("axios-loading") }
end

def wait_for_ajax_loaded(time = Capybara.default_max_wait_time)
  Timeout.timeout(time) { sleep(0.01) while page.find("body")[:class].include?("axios-loading") }
end

def wait_for_route_loading(time = Capybara.default_max_wait_time)
  Timeout.timeout(time) { sleep(0.01) until page.find("body")[:class].include?("route-loading") }
end

def wait_for_route_loaded(time = Capybara.default_max_wait_time)
  Timeout.timeout(time) { sleep(0.01) while page.find("body")[:class].include?("route-loading") }
end

def wait_for_turbo_loaded(time = Capybara.default_max_wait_time)
  Timeout.timeout(time) do
    if page.present? &&
        page.find("body").present? &&
        page.find("body")[:class].present? &&
        page.find("body")[:class].is_a?(String)

      sleep(0.01) until page.present? &&
          page.find("body").present? &&
          page.find("body")[:class].present? &&
          !page.find("body")[:class].to_s.include?("turbo-loading")
    else
      sleep 0.3
    end
  end
end

def wait_for_loaded
  wait_for_turbo_loaded
end
