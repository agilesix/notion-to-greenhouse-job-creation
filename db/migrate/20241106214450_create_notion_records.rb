class CreateNotionRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :notion_records do |t|
      t.string :notion_record_id

      t.timestamps
    end
  end
end
