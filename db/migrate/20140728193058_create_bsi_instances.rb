class CreateBsiInstances < ActiveRecord::Migration
  def change
    create_table :bsi_instances do |t|
      t.string :url
      t.string :name

      t.timestamps
    end
  end
end
