class Job < ActiveRecord::Base
  has_many :prompts
  has_many :dependencies, as: :attachable
  has_and_belongs_to_many :users
  accepts_nested_attributes_for :dependencies,  :allow_destroy => true
  accepts_nested_attributes_for :prompts,       :allow_destroy => true

  mount_uploader :core, LibFileUploader
  process_in_background :core

  def dependencies_for_form
    collection = dependencies.where(attachable_id: id)
    collection.any? ? collection : dependencies.build
  end

  def prompts_for_form
    collection = prompts.where(job_id: id)
    collection.any? ? collection : prompts.build
  end

  def upload_manifest
  end
end
