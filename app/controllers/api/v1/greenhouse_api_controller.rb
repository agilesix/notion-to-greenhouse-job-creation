class Api::V1::GreenhouseApiController < ApplicationController
  before_action :load_departments

  def map_pac_to_department(pac)
    practice_area = pac

    # Use practice_area as needed in this action
    Rails.logger.info("Practice Area: #{practice_area}")

    # render json: { practice_area: practice_area }
    # Find the department ID by iterating over the JSON data
    department_id = find_department_id(practice_area)

    # Use the department_id to create the job post or handle if not found
    if department_id
      create_job_post(department_id)
    else
      Rails.logger.info("Department not found for Practice Area Coach: #{pac}")
      render json: { error: "Department not found" }, status: :not_found
    end
  end

  def show
    notion_data = session[:notion_data]

    if notion_data.present? && notion_data[0].key?(:practice_area)
      practice_area = notion_data[0][:practice_area]
    else
      practice_area = "Practice area not available"
    end
    map_pac_to_department(practice_area)
  end
  debugger
  private

  def load_departments
    file_path = Rails.root.join("departments_list.json")
    @departments = JSON.parse(File.read(file_path))
  end

  def find_department_id(pac)
    @departments.each do |department_name, department_id|
      return department_id if department_name == pac
    end
  end



  # def create_job_post(department_id)
  #
  #   url = "https://harvest.greenhouse.io/v1/jobs"
  #   headers = { "Authorization" => "Basic  #{Base64.strict_encode64("#{ENV['GREENHOUSE_API_TOKEN']}:")} ",
  #               "Content-Type" => "application/json",
  #               "On-Behalf-Of" => "4114336003"
  #   }
  #   {
  #     "name": "Test Job Creation",
  #     "departments": [
  #       department_id
  #     ]
  #   }
  #   response = HTTParty.post(url, headers: headers, body: body.to_json)
  #   if response.success?
  #     puts "Job post created: #{response.body}"
  #   else
  #     puts "Failed to add candidate: #{response.code} - #{response.message}"
  #   end
  #
  # end
  #
  # def show
  #   url = "https://harvest.greenhouse.io/v1/jobs"
  #   headers = { "Authorization" => "Basic  #{Base64.strict_encode64("#{ENV['GREENHOUSE_API_TOKEN']}:")} ",
  #               "Content-Type" => "application/json",
  #               "On-Behalf-Of" => "4114336003"
  #   }
  #   response = HTTParty.get(url, headers:headers, body: body.to_json)
  #   if response.success?
  #     puts "Completed: #{response.body}"
  #   else
  #     puts "Failed to display: #{response.code} - #{response.message}"
  #   end
  #
  #
  # end
end
