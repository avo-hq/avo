require "rails_helper"

# Turbo re-runs every script on a page it renders from an error response. Booting the panel's bundle a
# second time starts a second Stimulus application, and every action then fires twice until a hard reload.
RSpec.describe "A refused Turbo visit", type: :system do
  it "keeps the panel's one Stimulus application" do
    visit "/admin/resources/users"
    page.execute_script("window.__stimulus = window.Stimulus")

    deny_the_users_list
    # The referrer is the page itself, so core renders the refusal rather than going back.
    page.execute_script("Turbo.visit(window.location.href)")

    expect(page).to have_text "You are not authorized to perform this action."
    expect(page.evaluate_script("window.Stimulus === window.__stimulus")).to be(true)
  end

  # What a visit from a host page's own Turbo looks like: Turbo is there and Avo's bundle has never run.
  it "loads the page in full when the panel's bundle hasn't booted" do
    visit "/admin/resources/users"
    page.execute_script("window.__before = true; delete window.Avo.localStorage")

    deny_the_users_list
    page.execute_script("Turbo.visit(window.location.href)")

    expect(page).to have_text "You are not authorized to perform this action."
    expect(page.evaluate_script("window.__before")).to be_nil
    expect(page.evaluate_script("!!window.Stimulus")).to be(true)
  end

  def deny_the_users_list
    allow_any_instance_of(Avo::Services::AuthorizationService).to receive(:authorize_action).and_wrap_original do |original, action, *args, **kwargs|
      if action.to_s.delete_suffix("?") == "index" && original.receiver.record == User
        next false if kwargs[:raise_exception] == false

        raise Avo::NotAuthorizedError
      end

      original.call(action, *args, **kwargs)
    end
  end
end
