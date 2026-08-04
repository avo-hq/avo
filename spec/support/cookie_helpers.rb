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
# page.driver.set_cookie(name, value, options) delegates to Ferrum's
# cookies.set; passing an explicit options Hash keeps it unambiguous across
# Ruby versions (the method takes a positional options Hash, not kwargs).
module CookieHelpers
  def set_browser_cookie(name, value, path: "/")
    page.driver.set_cookie(name, value.to_s, {path: path})
  end

  def remove_browser_cookie(name, path: "/")
    page.driver.remove_cookie(name, path: path)
  end
end

RSpec.configure do |config|
  config.include CookieHelpers, type: :system
end
