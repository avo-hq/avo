require "net/http"

class Avo::Actions::CheckLinkHealth < Avo::BaseAction
  self.name = "Check link health"
  self.message = "Pings each selected link and reports whether it's reachable."

  def handle(records:, **)
    alive = []
    broken = []

    records.each do |record|
      url = record.link.to_s
      uri = URI.parse(url)

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 3, read_timeout: 3) do |http|
        http.head(uri.request_uri.presence || "/")
      end

      if response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)
        alive << "##{record.id} (#{response.code})"
      else
        broken << "##{record.id} (#{response.code})"
      end
    rescue => e
      broken << "##{record.id} (#{e.class.name})"
    end

    if broken.empty?
      succeed "All #{alive.size} links reachable."
    else
      warn "Reachable: #{alive.join(", ").presence || "none"}. Broken: #{broken.join(", ")}."
    end
  end
end
