module Pipeline::BSI::Model::CustomFields
  def bsi_specimen_fields
    out = {
    }
    vial_fields.each do |attr|
      out[attr.to_sym] = "vial.#{attr}"
    end
    out
  end

  def vial_fields
    [
      'repos_id',
      'specimen_code',
      'original_id',
      'specimen_institution',
      'fixative',
      'vacutainer',
      'vial_status'
    ]
  end
end
