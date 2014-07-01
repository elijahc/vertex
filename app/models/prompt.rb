class Prompt < ActiveRecord::Base
  FIELD_TYPES = [
    :check_box,
    :color_field,
    :date_field,
    :datetime_field,
    :datetime_local_field,
    :email_field,
    :file_field,
    :hidden_field,
    :month_field,
    :number_field,
    :password_field,
    :phone_field,
    :radio_button,
    :range_field,
    :search_field,
    :text_area,
    :text_field,
    :time_field,
    :url_field,
    :week_field,
    :select_field
  ]

  belongs_to :job
  enum field_type: FIELD_TYPES

end
