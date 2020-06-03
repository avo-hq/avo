require 'timeout'

def wait_for_ajax_loading(time = Capybara.default_max_wait_time)
  Timeout.timeout(time) { sleep(0.01) until page.find('body')[:class].include?('axios-loading') }
end

def wait_for_ajax_loaded(time = Capybara.default_max_wait_time)
  Timeout.timeout(time) { sleep(0.01) until !page.find('body')[:class].include?('axios-loading') }
end

def wait_for_route_loading(time = Capybara.default_max_wait_time)
  Timeout.timeout(time) { sleep(0.01) until page.find('body')[:class].include?('route-loading') }
end

def wait_for_route_loaded(time = Capybara.default_max_wait_time)
  Timeout.timeout(time) { sleep(0.01) until !page.find('body')[:class].include?('route-loading') }
end

def wait_for_loaded
  wait_for_ajax_loaded and wait_for_route_loaded
end
