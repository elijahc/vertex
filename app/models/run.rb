class Run < ActiveRecord::Base
  belongs_to :job
  validates_presence_of :job_id
  validates_associated :job

  has_many   :prompt_values
  validates_associated :prompt_values

  def inputs
    hash = prompt_values.inject({}) do |result, elem|
      case elem.prompt.field_type
      when "file_field"
        result.merge(elem.prompt.label.to_s => elem.file)
      else
        result.merge(elem.prompt.label.to_s => elem.value)
      end
    end
    return hash
  end

  def status
    Sidekiq::Status::status uuid
  end

  def core
    Module.const_get(job.core.class_name)
  end

  def start(*args)
    ActiveRecord::Base.transaction do
      new_uuid = core.perform_async(*args)
      update_column(:uuid, new_uuid)
    end
    uuid
  end
end
