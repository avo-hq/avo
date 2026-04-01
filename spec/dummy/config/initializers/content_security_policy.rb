# Be sure to restart your server when you modify this file.
#
# Set `DUMMY_CSP_REPORT_ONLY=1` to enable CSP reporting in the dummy app.
if ENV["DUMMY_CSP_REPORT_ONLY"] == "1"
  Rails.application.config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  Rails.application.config.content_security_policy_nonce_directives = %w[script-src style-src]

  Rails.application.config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src :self, :https, :data
    policy.img_src :self, :https, :data
    policy.object_src :none
    policy.script_src :self, :https
    policy.style_src :self, :https
    policy.connect_src :self, :https, "http://localhost:3035", "ws://localhost:3035" if Rails.env.development?

    # Dummy endpoint that logs browser CSP violation payloads.
    policy.report_uri "/csp-violation-report-endpoint"
  end

  Rails.application.config.content_security_policy_report_only = true
end
