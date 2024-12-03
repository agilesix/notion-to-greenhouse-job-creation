class GreenhouseService
  BASE_URL = "https://harvest.greenhouse.io/"
  def self.create_job(notion_data, job_template_id, department_id, page_content) #may include additional parameter page_id to include content of job post
    url = "#{BASE_URL}v1/jobs"
    headers = { "Authorization" => "Basic  #{Base64.strict_encode64("#{ENV['GREENHOUSE_API_TOKEN']}:")} ",
                "Content-Type" => "application/json",
                "On-Behalf-Of" => "4114336003"
    }

    payload = {
      template_job_id: job_template_id,
      number_of_openings: 1,
      job_post_name: "#{notion_data[:position_title]} test 2", # External Name
      job_name: "#{notion_data[:pd_title]} #{notion_data[:project]}",     # Internal Name
      department_id: department_id # Ensure this is mapped correctly
      # page_content: page_content[:id]   # Example of generating a unique requisition ID
    }
    Rails.logger.debug("Mapping check - template_job_id: #{job_template_id}")
    Rails.logger.debug("Mapping check - position_title: #{notion_data[:position_title]}")
    Rails.logger.debug("Mapping check - department_id: #{notion_data[:practice_area]}")
    Rails.logger.debug("Mapping check - page_id: #{notion_data[:id]}")
    response = HTTParty.post(url, headers: headers, body: payload.to_json)
    # debugger
      # "Debugging - template_id output: #{job_template_id}
    # job_template_id
    # TODO: make all function calls from the notion_to_greenhouse_service.call function
    job_id = response.parsed_response["id"]
    job_id
    # extract job post ID for the job that was created
    if response.present?
      pull_job_post(job_id, notion_data, page_content)
    end

    # patch the job post to meet the data requirements
  end

  def self.pull_job_post(job_id, notion_data, page_content)
    url = "#{BASE_URL}v1/jobs/#{job_id}/job_posts"
    headers = { "Authorization" => "Basic  #{Base64.strict_encode64("#{ENV['GREENHOUSE_API_TOKEN']}:")} ",
                "Content-Type" => "application/json",
                "On-Behalf-Of" => "4114336003"
    }

    response = HTTParty.get(url, headers: headers)
    # response
    # debugger
    job_post_id = response.parsed_response[0]["id"]
    job_post_id
    # debugger
    if response.present?
      patch_job_post(job_post_id, notion_data, page_content)
    end
    # debugger
  end
  def self.patch_job_post(job_post_id, notion_data, page_content)
    # debugger
    url = "#{BASE_URL}v2/job_posts/#{job_post_id}"
    headers = { "Authorization" => "Basic  #{Base64.strict_encode64("#{ENV['GREENHOUSE_API_TOKEN']}:")} ",
                "Content-Type" => "application/json",
                "On-Behalf-Of" => "4114336003"
    }

    payload = {
      title: "#{notion_data[:pd_title]} #{notion_data[:project]}", # External Name
      location: "Remote",     # Internal Name
      content: page_content.to_s
    }
    response = HTTParty.patch(url, headers: headers, body: payload.to_json)
    if response.present?
      "The #{job_post_id} for #{notion_data[:pd_title]} #{notion_data[:project]} has been created"
    end
  end
  def self.pull_job_templates

    url = "#{BASE_URL}v1/jobs?per_page=500&status=open"
    headers = { "Authorization" => "Basic #{Base64.strict_encode64("#{ENV['GREENHOUSE_API_TOKEN']}:")} ",
                "Content-Type" => "application/json" }
    response = HTTParty.get(url, headers: headers)

    if response.code != 200
      Rails.logger.error("Failed to fetch job templates: #{response.message}")
      return []
    end

    response.parsed_response.select { |job| job["is_template"] == true }

  end
  def self.check_job_creation(job_id)
    # basic auth
    url = "#{BASE_URL}v1/#{job_id}"
    headers = { "Authorization" => "Basic #{Base64.strict_encode64("#{ENV['GREENHOUSE_API_TOKEN']}:")} ",
                "Content-Type" => "application/json" }
    response = HTTParty.get(url, headers: headers)
  end
  def self.check_job_post_creation(job_id)
    url = "#{BASE_URL}/v1/jobs/#{job_id}/job_posts"
    headers = { "Authorization" => "Basic #{Base64.strict_encode64("#{ENV['GREENHOUSE_API_TOKEN']}:")} ",
                "Content-Type" => "application/json" }
    response = HTTParty.get(url, headers: headers)
  end
  def self.check_job_post(job_post_id)
    url = "#{BASE_URL}/v1/job_posts/#{job_post_id}"
    headers = { "Authorization" => "Basic #{Base64.strict_encode64("#{ENV['GREENHOUSE_API_TOKEN']}:")} ",
                "Content-Type" => "application/json" }
    response = HTTParty.get(url, headers: headers)
  end
  def self.load_job_template_id
    file_path = Rails.root.join("template_ids.json") #gpt code
    @templates = JSON.parse(File.read(file_path)) #gpt code
    # match = @templates.find { |template| template["name"] == position_title }
    # match ? match["id"] : nil # Return the template ID if found
  end

  def self.template_id(position_title)
    load_job_template_id unless @templates
    match = @templates.find { |template| template["name"] == position_title } #gpt code
    match ? match["id"] : nil #gpt code
    # @templates.find { |tid| position_title == tid["name"] }
  end
end
#   file_path = "template_ids.json"
#   # basic auth
#   # TODO need to figure out how to keep response in auth function, but be able to change the http request
#   url = "https://harvest.greenhouse.io/v1/jobs"
#   headers = { "Authorization" => "Basic  #{Base64.strict_encode64("#{ENV['GREENHOUSE_API_TOKEN']}:")} ",
#               "Content-Type" => "application/json",
#               "On-Behalf-Of" => "4114336003"
#   }
#   response = HTTParty.get(url, headers: headers)
#   data = response.parsed_response
#
#   # want to call authentication to greenhouse in the future
#   # data = auth_to_greenhouse("https://harvest.greenhouse.io/v1/jobs")
#
#   # filter for '"is_template": true'
#   updated_data = data.select { |job| job["is_template"] == true }
#   # update existing template_ids.json file
#   File.open(file_path, "w") do |file|
#     file.write(JSON.pretty_generate(updated_data))  # Use `pretty_generate` for human-readable format
#   end
#
#   "File updated successfully."
# end

# def post_to_greenhouse()
#   response = HTTParty.post(url, headers: headers)
# end
# def get_from_greenhouse()
#   response = HTTParty.get(url, headers: headers)
# end
# def self.auth_to_greenhouse_(url)
#   headers = { "Authorization" => "Basic  #{Base64.strict_encode64("#{ENV['GREENHOUSE_API_TOKEN']}:")} ",
#               "Content-Type" => "application/json",
#               "On-Behalf-Of" => "4114336003"
#   }
#   response = HTTParty.get(url, headers: headers)
#   response.parsed_response
# end