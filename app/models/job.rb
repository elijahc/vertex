class Job < ActiveRecord::Base
  has_and_belongs_to_many :users

  def prompts
  end

  def type
  end

  def upload_manifest
  end
end
