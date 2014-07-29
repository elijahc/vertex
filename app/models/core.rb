class Core < ActiveRecord::Base
  has_many :jobs
  validates_presence_of :class_name

  def worker_class
    klass = nil
    begin
      klass = Module.const_get(class_name)
    rescue
    end
    klass
  end
end
