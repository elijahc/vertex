class CreateCores < ActiveRecord::Migration
  def change
    create_table :cores do |t|
      t.string :class_name

      t.timestamps
    end
  end
end
