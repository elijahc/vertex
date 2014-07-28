class Core < ActiveRecord::Base
  has_many :jobs
  validates_presence_of :class_name
end
