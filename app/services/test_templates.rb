class TestTemplates
  def self.pull_templates
    url = "https://harvest.greenhouse.io/v1/jobs"
    headers = { "Authorization" => "Basic #{Base64.strict_encode64("#{ENV['GREENHOUSE_API_TOKEN']}:")} ",
                "Content-Type" => "application/json" }
    response = HTTParty.get(url, headers: headers)

    if response.code != 200
      Rails.logger.error("Failed to fetch job templates: #{response.message}")
    end
  end
end