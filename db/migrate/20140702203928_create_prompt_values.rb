class CreatePromptValues < ActiveRecord::Migration
  def change
    create_table :prompt_values do |t|
      t.string      :value
      t.string      :value_type
      t.string      :file

      t.references  :prompt,      :index => true
      t.references  :run, :index => true

      t.timestamps
    end
  end
end
