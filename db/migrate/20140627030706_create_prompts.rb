class CreatePrompts < ActiveRecord::Migration
  def change
    create_table :prompts do |t|
      t.integer :field_type
      t.string  :label
      t.integer :job_id

      t.timestamps
    end
  end
end
