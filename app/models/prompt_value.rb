class PromptValue < ActiveRecord::Base
  belongs_to  :run
  validates_associated :run
  belongs_to  :prompt
  validates_associated :prompt

  validates_presence_of :value

  mount_uploader :file, TmpFileUploader

end
