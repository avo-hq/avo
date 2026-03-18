class CspReportsController < ActionController::Base
  skip_before_action :verify_authenticity_token, only: :create

  def create
    payload = request.raw_post.presence || "{}"
    parsed_payload = JSON.parse(payload)

    Rails.logger.warn("[CSP REPORT] #{JSON.pretty_generate(parsed_payload)}")

    head :no_content
  rescue JSON::ParserError
    Rails.logger.warn("[CSP REPORT] Unparseable payload: #{payload}")
    head :bad_request
  end
end
