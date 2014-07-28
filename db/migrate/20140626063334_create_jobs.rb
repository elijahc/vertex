class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :name
      t.string :job_type
      t.string :spec
      t.references :core
      t.string    :parser

      t.timestamps
    end
  end
end
