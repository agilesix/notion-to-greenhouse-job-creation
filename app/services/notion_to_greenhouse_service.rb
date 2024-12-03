class NotionToGreenhouseService


  def self.call
    # call to notion to get list of staff workflow records

    notion_data = NotionService.notion_query
    # block_id = notion_data[:id]
    notion_data.each do |notion_record|
      # debugger
      unless notion_record[:position_title] && notion_record[:practice_area]
        puts "Missing key in notion_record: #{notion_record.inspect}"
        next
      end
      # check database to see if job has been made for notion record id in greenhouse, skip duplicate record is found
      next if NotionRecord.where(notion_record_id: notion_record[:id]).any?

      # page_content = NotionService.pull_page_id(NotionRecord.where(notion_record_id: notion_record[:id]))
      job_templates = GreenhouseService.pull_job_templates #page_content additional parameter if necessary
      job_template = job_templates.find{|jt| jt["name"] == notion_record[:position_title] }
      # debugger
      job_template_id = job_template["id"]
      next unless job_template_id
      department_id = job_template["departments"].first["id"]
      block_id = notion_record[:id]
      page_content = NotionService.pull_page_id(block_id)
      # check for specific columns to see if job is ready to be made in greenhouse
      # next unless ready_for_greenhouse?(notion_record)
      # debugger
      create_job = GreenhouseService.create_job(notion_record, job_template_id, department_id, page_content)
      # check greenhouse response to ensure job was created or error out
      # GreenhouseService.check_job_creation(notion_record[:id])

      # check to see if job_post has been created
      # job_post_id = create_job.parsed_response["id"]

      # GreenhouseService.check_job_post_creation(job_post_id)
      # do you fail the whole loop if record errors out


      # debugger
      # create notion record denoting job was created
      NotionRecord.create(notion_record_id: notion_record[:id])
    end
  end

  # def self.ready_for_greenhouse?(notion_record)
  #   position_title = notion_record[:position_title]
  #   status = notion_record[:status]
  #   ready_for_greenhouse = notion_record[:ready_for_greenhouse]
  #   target_hire_date = notion_record[:target_hire_date]
  #   position_title.present? && status=="Recruiting" && ready_for_greenhouse.present? && target_hire_date.present?
  # end
end
