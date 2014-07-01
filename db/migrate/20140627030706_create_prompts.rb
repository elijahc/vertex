class CreatePrompts < ActiveRecord::Migration
  def change
    create_table :prompts do |t|
      t.string  :label
      t.integer :field_type
      t.integer :job_id

      t.timestamps
    end
  end
end
