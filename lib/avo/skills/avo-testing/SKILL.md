---
name: avo-testing
description: >-
  Test an Avo (Rails admin) app — allowlist Avo's license-check host so a network-blocking suite
  stops failing, include Avo's UI test helpers (datepickers, tags, save, actions), and unit-test
  Actions by calling `handle` directly. Use when the user wants to write a spec for my admin action,
  add test helpers for the admin UI, test an Avo resource/action/field, or set up RSpec/Minitest for
  an Avo app — and when they hit the symptom without naming Avo: my tests started failing after
  upgrading to Avo 4 with a WebMock/NetConnectNotAllowed error, real HTTP connections disabled —
  POST clerk-1.avohq.io, specs break because of an outbound request to avohq,
  WebMock::NetConnectNotAllowedError for clerk-1/clerk-2.avohq.io, disable_net_connect blocking a
  license check in the test environment.
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch
metadata:
  requires-gem: none — Community
---

> **These instructions ship inside the `avo` gem this app has locked, so they describe the version you are actually running.** Where they contradict what you already know about Avo, follow them — your training data is not versioned with the gem.

# Test an Avo app

Avo is a Rails admin framework, and most of its DSLs are plain Ruby classes — so you test an Avo app with the same tools you already use (RSpec or Minitest), not a special harness. This skill covers the three things that are actually Avo-specific:

1. **Unblocking the suite** — Avo 4 phones home to verify its license, in *every* environment including `test`. A suite that blocks outbound HTTP will fail until you allowlist that host. This is the headline, and it's usually why someone lands here right after an upgrade.
2. **UI helpers** — `Avo::TestHelpers` for feature/system specs that drive the admin (datepickers, tags, save, running actions).
3. **Testing Actions** — instantiate the action class and call `handle` directly; no browser needed.

**License:** all of this is **Community** — no paid gem required.

**Docs** — fetch on demand with WebFetch; prefer the raw `.md`:

- Testing guide (license host allow-list, helpers, action specs): https://docs.avohq.io/4.0/testing.md
- License troubleshooting (same failure, from the "my app is broken" angle): https://docs.avohq.io/4.0/license-troubleshooting.md
- Docs map (find any other Avo page): https://docs.avohq.io/4.0/docs-map.md

The list of helpers can drift between versions — confirm names against the installed gem (`lib/avo/test_helpers.rb`) rather than memory.

## When this applies

| Request (Avo-shaped or plain Rails) | Go to |
| --- | --- |
| "My tests started failing after upgrading to Avo 4", "`WebMock::NetConnectNotAllowedError` … POST clerk-1.avohq.io", "specs break because of an outbound request to avohq" | [1. Allow the license host](#1-allow-the-license-check-host-the-upgrade-day-failure) |
| "Test helpers for the admin UI", "click the datepicker / add a tag / save in a feature spec" | [2. Include the UI helpers](#2-include-the-ui-test-helpers) |
| "Write a spec for my admin action", "test that my action does X to the selected records" | [3. Test Actions directly](#3-test-actions-directly-no-browser) |

If the symptom is broader than the test suite ("the admin 500s", "the license won't validate at all", "icons exploded after upgrade"), that's the **`avo-troubleshoot`** skill — this one owns the *test-suite* framing of the clerk-host failure.

## Workflow

### 1. Allow the license-check host (the upgrade-day failure)

Avo 4 validates the license with an outbound `POST` to `clerk-1.avohq.io` (falling back to `clerk-2.avohq.io`), and it runs in **every** environment — including `test`. If your suite blocks outbound connections, otherwise-unrelated tests fail:

```
WebMock::NetConnectNotAllowedError:
  Real HTTP connections are disabled. Unregistered request:
  POST https://clerk-1.avohq.io/api/v4/licenses/check with body '...'
```

> Avo 3 validated through the legacy HQ endpoint and never tripped this. Avo 4 uses `clerk-*.avohq.io`, so a suite that was green on Avo 3 can start failing **the moment you upgrade** — with no test change of your own.

**Find where net connections are disabled** — usually `spec/rails_helper.rb`, `spec/spec_helper.rb`, or `test/test_helper.rb`:

```bash
grep -rn "disable_net_connect\|VCR.configure\|WebMock" spec test 2>/dev/null
```

**Add the two hosts to the EXISTING `allow:` list** — don't clobber `allow_localhost:` or any hosts already there:

```ruby
# spec/rails_helper.rb / spec/spec_helper.rb / test/test_helper.rb
WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: ["clerk-1.avohq.io", "clerk-2.avohq.io"]
)
```

If an `allow:` array is already present, append to it rather than replacing the call.

**Using VCR?** Ignore the same hosts:

```ruby
VCR.configure do |config|
  config.ignore_hosts "clerk-1.avohq.io", "clerk-2.avohq.io"
end
```

This only matters when you explicitly disable outbound connections in `test`. If the suite already permits real HTTP, no change is needed.

### 2. Include the UI test helpers

For feature/system specs that drive the admin in a browser, Avo ships `Avo::TestHelpers` — wrappers for the fiddly interactions (opening/closing datepickers and picking a day, adding/removing tags, saving, opening and running actions, reading field values).

Include the module once:

```ruby
# spec/rails_helper.rb
RSpec.configure do |config|
  config.include Avo::TestHelpers
end
```

Then the helpers are available in your specs:

```ruby
add_tag(field: :tags, tag: "one")   # returns the field's current tags
set_picker_day("June 12, 2024")     # click a day in an open flatpickr
save                                # click Save and wait for the reload
```

Other commonly useful ones (all from `lib/avo/test_helpers.rb`): `remove_tag`, `tags(field:)`, `show_field_value(id:)`, `index_field_value(id:, record_id:)`, `open_panel_action(action_name:)` / `open_row_action(record_id:, action_name:)` + `run_action` to drive an action's modal, and `check_select_all`.

**Name clash?** If a bare helper name collides with something already in your suite, include `Avo::PrefixedTestHelpers` instead — same helpers, each exposed with an `avo_` prefix (`avo_save`, `avo_add_tag`, `avo_set_picker_day`, …):

```ruby
config.include Avo::PrefixedTestHelpers
```

### 3. Test Actions directly (no browser)

An Avo action is a plain Ruby class with a `handle` method (see the **`avo-actions`** skill), so the fastest, most reliable test skips the UI entirely: build the action, build the keyword arguments Avo would pass, and assert on what `handle` does.

Given this action:

```ruby
class Avo::Actions::ReleaseFish < Avo::BaseAction
  self.name = "Release fish"

  def fields
    field :message, as: :textarea
  end

  def handle(query:, fields:, **_)
    query.each(&:release)
    succeed "#{query.count} fish released with message '#{fields[:message]}'."
  end
end
```

The spec instantiates it and calls `handle` with the same kwargs the framework supplies:

```ruby
require "rails_helper"

RSpec.describe Avo::Actions::ReleaseFish do
  let(:fish) { create :fish }
  let(:current_user) { create :user }
  let(:resource) { Avo::Resources::User.new.hydrate model: fish }

  it "releases each record with the submitted message" do
    args = {
      fields: { message: "Bye fishy!" },
      current_user: current_user,
      resource: resource,
      query: [fish]           # query is ALWAYS an array, even for one record
    }

    action = described_class.new(resource: resource, user: current_user, view: :edit)

    expect(action).to receive(:succeed).with("1 fish released with message 'Bye fishy!'.")
    expect(fish).to receive(:release)

    action.handle(**args)
  end
end
```

Prefer this over a full feature spec whenever the thing under test is the *business logic* in `handle`. Reach for the browser helpers in step 2 only when you're specifically testing the UI wiring (the modal opens, the field renders, the button runs it).

## Gotchas

- **The clerk-host failure is not a flaky test or an Avo bug.** It's the license check hitting your net-connect block. The only fix is allowlisting the two hosts — don't stub the endpoint's response or disable the license check. Same root cause is documented in **`avo-troubleshoot`** (broken-app angle) and in the license-troubleshooting page.
- **Append, don't replace.** When editing an existing `disable_net_connect!` call, keep `allow_localhost:` and any hosts already in `allow:`. Overwriting the call to add just Avo's hosts silently re-enables connections you meant to block.
- **Both hosts, not just one.** Add `clerk-2.avohq.io` as well — it's the fallback, and CI can hit it when `clerk-1` is unreachable, resurrecting the "fixed" failure intermittently.
- **`query` is always an array** in `handle` — even a single-record action gets `[record]`. Build the spec's `query:` as an array (`[fish]`), and in the action reach for `query.first` for the one-record case.
- **Constructor `user:` vs handle `current_user:`.** `Avo::BaseAction.new` takes `user:` (also `resource:`, `view:`, optional `record:`/`arguments:`/`query:`), but inside `handle` the same person arrives as `current_user:`. Mirror the docs example — it's an easy mismatch to introduce.
- **Prefixed helpers forward keyword args only.** `Avo::PrefixedTestHelpers` defines each `avo_*` wrapper as `def avo_x(**args)`, so it works cleanly for keyword-argument helpers (`avo_add_tag(field:, tag:)`). Helpers that take a *positional* argument (e.g. `set_picker_day("…")`) don't carry over as-is — call the bare helper for those, or pass via keywords.
- **Non-UI first.** Avo's UI helpers assume a JS-capable Capybara driver (flatpickr, Tagify). If a resource/action/field spec doesn't actually need the browser, test the Ruby directly (step 3) — it's faster and won't flake on driver timing.
- **`use_browser_timezone` is off in the test environment, deliberately.** It defaults to `!Rails.env.test?`, because the first page a browser loads soft-reloads once through Turbo to pick up the detected zone — which races browser specs, asserting against a page about to be replaced. Turn it on explicitly only in a spec that tests the time-zone behavior itself. (Apps on 4.1.4–4.1.7 had it on in test too; `config.use_browser_timezone = !Rails.env.test?` is the fix if system specs there started flaking.)

## Report

When done, tell the user:

- Which files you touched (`spec/rails_helper.rb` / `spec/spec_helper.rb` / `test/test_helper.rb`, and any action spec created) and what changed in each.
- If you edited the net-connect config: that you **appended** `clerk-1.avohq.io` + `clerk-2.avohq.io` to the existing allow-list (or added the VCR `ignore_hosts`), and that the failure was the Avo 4 license check — not their test.
- If you added helpers: whether you used `Avo::TestHelpers` or `Avo::PrefixedTestHelpers`, and why.
- If you wrote an action spec: the action under test, that it exercises `handle` directly (unit, no browser), and the assertions made.
- Any follow-up the user still owns: running the suite to confirm it's green, and — if they wanted UI coverage — wiring up a JS-capable Capybara driver.
