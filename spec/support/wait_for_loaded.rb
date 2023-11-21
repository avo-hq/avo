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
  sleep 0.05
  wait_for_body_class_missing("search-loading", time)
end

def wait_for_search_to_dissapear(time = Capybara.default_max_wait_time)
  wait_for_element_missing(".aa-DetachedOverlay", time)
end

def wait_for_turbo_frame_id(frame_id = "", time = Capybara.default_max_wait_time)
  wait_for_element_missing("turbo-frame[id='#{frame_id}'][busy]", time)
end

def wait_for_turbo_frame_src(frame_src = "", time = Capybara.default_max_wait_time)
  wait_for_element_missing("turbo-frame[src='#{frame_src}'][busy]", time)
end

def wait_for_body_class_missing(klass = "turbo-loading", time = Capybara.default_max_wait_time)
  Timeout.timeout(time) do
    body = page.find(:xpath, "//body")
    if page.present? && body.present? && body[:class].present? && body[:class].is_a?(String)
      sleep(0.05) until page.present? && !body[:class].to_s.include?(klass)
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
      sleep 0.05
    end
  end
end

def wait_for_loaded
  wait_for_turbo_loaded
end

def wait_for_action_dialog_to_disappear(time = Capybara.default_max_wait_time)
  wait_for_element_missing("[role='dialog']", time)
end

def wait_for_tag_to_disappear(tag, time = Capybara.default_max_wait_time)
  Capybara.using_wait_time(time) do
    page.has_no_css?(".tagify__tag", text: tag)
  end
end

def wait_for_tag_to_appear(tag, time = Capybara.default_max_wait_time)
  Capybara.using_wait_time(time) do
    page.has_css?(".tagify__tag", text: tag)
  end
end

def wait_for_tag_suggestions_to_appear(time = Capybara.default_max_wait_time)
  Capybara.using_wait_time(time) do
    page.has_css?(".tagify__dropdown")
  end
end
