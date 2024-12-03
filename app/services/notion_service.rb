class NotionService
  def self.notion_query
    response = NOTION_CLIENT.database_query(
      database_id: "12ac834336d880c1bb72f99bfa8b04ef",
      filter: {
        and: [
          {
            property: "Status",
            status: {
              equals: "Recruiting"
            }
          },
          {
            property: "Position Title",
            rich_text: {
              is_not_empty: true
            }
          },
          {
            property: "Ready for Greenhouse?",
            checkbox: {
              equals: true
            }
          },
          {
            property: "Target Hire Date",
            date: {
              is_not_empty: true
            }
          }
        ]
      }
    )
    response["results"].map do |result|
      {
        id: result["id"],
        priority: result.dig("properties", "Priority", "select", "name"),
        project: result.dig("properties", "Project", "select", "name"),
        position_title: result.dig("properties", "Position Title", "title", 0, "text", "content"),
        status: result.dig("properties", "Status", "status", "name"),
        ordering_vehicle: result.dig("properties", " Ordering Vehicle", "select", "name"),
        naics: result.dig("properties", "NAICS (if GSA)", "select", "name"),
        lcat: result.dig("properties", "LCAT", "select", "name"),
        key_personnel: result.dig("properties", "Key Personnel", "checkbox"),
        a6_level: result.dig("properties", "A6 Level", "select", "name"),
        filled_by: result.dig("properties", "Filled By", "select", "name"),
        education_requirement: result.dig("properties", "Education Requirement", "multi_select", 0, "name"),
        years_experience: result.dig("properties", "Years of Experience", "number"),
        tech_stack: result.dig("properties", "Tech Stack", "multi_select", 0, "name"),
        practice_area: result.dig("properties", "Practice Area", "select", "name"),
        employment_type: result.dig("properties", "Employment Type", "select", "name"),
        pd_title: result.dig("properties", "PD Title", "rich_text", 0, "text", "content")
      }
    end
  end
  def self.pull_page_id(page_id)
    blocks = []
    next_cursor =nil
    loop do
      # Build the request parameters dynamically
      request_params = { block_id: page_id }
      request_params[:start_cursor] = next_cursor if next_cursor

      # Fetch blocks from Notion API
      response = NOTION_CLIENT.block_children(**request_params)
      Rails.logger.debug("Response: #{response.inspect}")
      blocks += response["results"]

      # Break the loop if there are no more pages
      break unless response["has_more"]

      # Update the cursor for the next page
      next_cursor = response["next_cursor"]
    end
    Rails.logger.debug("Blocks: #{blocks.inspect}")
    debugger
    html_content = transform_blocks_to_html(blocks)

    Rails.logger.debug("HTML Content: #{html_content.inspect}")
    html_content
  end

  def self.transform_blocks_to_html(blocks)
    blocks.map do |block|
      case block.type
      when "paragraph"
        content = parse_rich_text(block.paragraph.rich_text)
        "<p>#{content}</p>"
      when "heading_1"
        content = parse_rich_text(block.heading_1.rich_text)
        "<h1>#{content}</h1>"
      when "heading_2"
        content = parse_rich_text(block.heading_2.rich_text)
        "<h2>#{content}</h2>"
      when "heading_3"
        content = parse_rich_text(block.heading_3.rich_text)
        "<h3>#{content}</h3>"
      when "bulleted_list_item"
        content = parse_rich_text(block.bulleted_list_item.rich_text)
        "<ul><li>#{content}</li></ul>"
      when "numbered_list_item"
        content = parse_rich_text(block.numbered_list_item.rich_text)
        "<ol><li>#{content}</li></ol>"
      else
        # Skip unsupported block types
        Rails.logger.debug("Unsupported block type: #{block.type}")
        ""
      end
    end.join("\n")
  end

  def self.parse_rich_text(rich_text_array)
    return "" if rich_text_array.nil? || rich_text_array.empty?

    rich_text_array.map do |text_object|
      content = text_object.plain_text
      annotations = text_object.annotations

      # Apply formatting
      formatted_content = content
      formatted_content = "<b>#{formatted_content}</b>" if annotations.bold
      formatted_content = "<i>#{formatted_content}</i>" if annotations.italic
      formatted_content = "<u>#{formatted_content}</u>" if annotations.underline
      formatted_content = "<s>#{formatted_content}</s>" if annotations.strikethrough
      formatted_content = "<code>#{formatted_content}</code>" if annotations.code

      formatted_content
    end.join("")
  end
end
