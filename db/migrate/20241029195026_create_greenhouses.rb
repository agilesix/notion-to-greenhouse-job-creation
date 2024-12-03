class CreateGreenhouses < ActiveRecord::Migration[7.2]
  def change
    create_table :greenhouses do |t|
      t.string :job
      t.string :department
      t.integer :requisition

      t.timestamps
    end
  end
end
