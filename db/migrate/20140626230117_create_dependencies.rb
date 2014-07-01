class CreateDependencies < ActiveRecord::Migration
  def change
    create_table :dependencies do |t|
      t.text :description
      t.string :lib
      t.references :attachable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
