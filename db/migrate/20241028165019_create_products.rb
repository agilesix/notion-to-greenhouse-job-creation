class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :pd
      t.date :hire
      t.string :status
      t.boolean :greenhouse

      t.timestamps
    end
  end
end
