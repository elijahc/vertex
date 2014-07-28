class Dependency < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true
  validates_presence_of :lib

  mount_uploader :lib, LibFileUploader
end
