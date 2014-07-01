class AddCoreToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :core, :string
  end
end
