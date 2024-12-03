require 'notion-ruby-client'

NOTION_CLIENT = Notion::Client.new(token: ENV['NOTION_API_TOKEN'])

