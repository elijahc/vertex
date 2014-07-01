class Dependency < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true

  mount_uploader :lib, LibFileUploader
end
