# Sets/removes a browser cookie in Cuprite system specs. Nothing in the suite
# set a cookie from a spec before the resizable-sidebar work, so this is new
# ground — two ordering constraints, both load-bearing:
#
#   1. An origin must already exist before a cookie can be scoped to a domain.
#      Cuprite derives the domain from the current page, so call `visit`
#      (a throwaway visit is fine) at least once before set_browser_cookie.
#   2. Capybara.reset_sessions! clears cookies. The sidebar specs call it in
#      their `before`, so set the cookie AFTER any reset_sessions! and then
#      re-visit for the server to read it on the next request.
#
# Cuprite 0.21 dropped page.driver.set_cookie and remove_cookie, so this calls
# Ferrum's cookies directly, with the domain those methods used to fill in.
module CookieHelpers
  def set_browser_cookie(name, value, path: "/")
    page.driver.browser.cookies.set(name: name, value: value.to_s, path: path, domain: cookie_domain)
  end

  def remove_browser_cookie(name, path: "/")
    page.driver.browser.cookies.remove(name: name, path: path, domain: cookie_domain)
  end

  private

  def cookie_domain
    URI.parse(page.current_url).host
  end
end

RSpec.configure do |config|
  config.include CookieHelpers, type: :system
end
