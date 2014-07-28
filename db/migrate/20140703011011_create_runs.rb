class CreateRuns < ActiveRecord::Migration
  def change
    create_table :runs do |t|
      t.string      :uuid
      t.references  :job
      t.timestamps
    end
  end
end
