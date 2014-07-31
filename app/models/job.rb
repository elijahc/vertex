class Job < ActiveRecord::Base
  has_many :prompts
  accepts_nested_attributes_for :prompts, :allow_destroy => true
  validates_associated :prompts

  belongs_to :core
  validates_presence_of :core_id

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

  def add_required_prompts_from_core
    req_prompts = core.worker_class.required_prompts
    prompt_list = prompts.map{|p| p.label}
    (req_prompts.keys - prompt_list).each do |p|
      new_prompt = Prompt.new(job_id: id, field_type: req_prompts[p], label: p)
      prompts << new_prompt
    end
  end

end
