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
  wait_for_body_class_missing("turbo-loading", time)
end

def wait_for_search_loaded(time = Capybara.default_max_wait_time)
  wait_for_body_class_missing("search-loading", time)
end

def wait_for_search_to_dissapear(time = Capybara.default_max_wait_time)
  wait_for_element_missing(".aa-DetachedOverlay", time)
end

def wait_for_body_class_missing(klass = "turbo-loading", time = Capybara.default_max_wait_time)
  Timeout.timeout(time) do
    if page.present? &&
        page.find("body").present? &&
        page.find("body")[:class].present? &&
        page.find("body")[:class].is_a?(String)

      sleep(0.01) until page.present? && !page.find("body")[:class].to_s.include?(klass)
    else
      sleep 0.1
    end
  end
end

def wait_for_element_missing(identifier = ".element", time = Capybara.default_max_wait_time)
  Timeout.timeout(time) do
    if page.present?
      break if page.has_no_css?(identifier, wait: time)
    else
      sleep 0.01
    end
  end
end

def wait_for_loaded
  wait_for_turbo_loaded
end
