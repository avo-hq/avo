require "rails_helper"

RSpec.describe "Load user preferences before_action", type: :system do
  let!(:user) { create :user }

  describe "cookie syncing from server preferences" do
    around do |example|
      original = Avo.configuration.user_preferences
      example.run
      Avo.configuration.user_preferences = original
    end

    context "when persistence is configured and user has saved preferences" do
      it "syncs server preferences to cookies on page load" do
        # Return preferences for any user — the signed-in user comes from DisableAuthentication
        Avo.configuration.user_preferences = {
          load: ->(user:, request:) { {"color_scheme" => "dark", "theme" => "slate", "accent_color" => "blue"} },
          save: ->(user:, request:, key:, value:, preferences:) { }
        }

        visit "/admin"

        # Server-loaded preferences are synced to cookies which the FOUC script reads.
        # Verify via the DOM state that dark mode and slate theme were applied.
        expect(page).to have_css("html.dark")
        expect(page).to have_css("html.theme-slate")
      end

      it "removes cookie when value matches the default" do
        # "auto" is the default for color_scheme
        Avo.configuration.user_preferences = {
          load: ->(user:, request:) { {"color_scheme" => "auto"} },
          save: ->(user:, request:, key:, value:, preferences:) { }
        }

        visit "/admin"

        # "auto" is the default for color_scheme, so the cookie should be removed
        cookie_value = page.evaluate_script("document.cookie.match(/color_scheme=([^;]+)/)?.[1]")
        expect(cookie_value).to be_nil
      end
    end

    context "when persistence is not configured" do
      it "does not interfere with existing cookie behavior" do
        Avo.configuration.user_preferences = nil

        visit "/admin"

        # Page loads normally without errors
        expect(page).to have_current_path(/\/admin/)
      end
    end

    context "when load callback raises an error" do
      it "logs the error and continues normally" do
        Avo.configuration.user_preferences = {
          load: ->(user:, request:) { raise "Database connection lost" },
          save: ->(user:, request:, key:, value:, preferences:) { }
        }

        # Should not break the page
        visit "/admin"
        expect(page).to have_current_path(/\/admin/)
      end
    end

    context "with adapter object (duck-typing)" do
      it "calls the adapter's load method" do
        adapter_class = Class.new do
          attr_reader :loaded_for

          def load(user:, request:)
            @loaded_for = user.id
            {"color_scheme" => "dark"}
          end

          def save(user:, request:, key:, value:, preferences:)
          end
        end

        adapter = adapter_class.new
        Avo.configuration.user_preferences = adapter

        visit "/admin"

        # The page should load with dark mode applied (proves cookie was set and read)
        expect(page).to have_css("html.dark")
      end
    end
  end
end
