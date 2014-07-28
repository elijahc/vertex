class Job < ActiveRecord::Base
  has_many :prompts
  accepts_nested_attributes_for :prompts, :allow_destroy => true
  validates_associated :prompts

  belongs_to :core
  validates_presence_of :core_id

  has_many :dependencies, as: :attachable
  accepts_nested_attributes_for :dependencies, :allow_destroy => true
  validates_associated :dependencies

  has_and_belongs_to_many :users

  has_many :runs

  def dependencies_for_form
    collection = dependencies.where(attachable_id: id)
    collection.any? ? collection : dependencies.build
  end

  def prompts_for_form
    collection = prompts.where(job_id: id)
    collection.any? ? collection : prompts.build
  end

end
