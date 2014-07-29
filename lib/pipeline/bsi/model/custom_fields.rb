module Pipeline::BSI::Model::CustomFields
  def bsi_specimen_fields
    out = {
      :timepoint            => 'sample.time_point',
      :surgical_case_number => 'sample.surgical_case_number',
      :surgical_case_part   => 'sample.field_273',
      :measurement_est      => 'vial.volume_est',
      :measurement_unit     => 'vial.volume_unit',
      :stain_type           => 'vial.field_268',
      :block_status         => 'vial.field_266',
      :grade                => 'vial.field_271'
    }
    vial_fields.each do |attr|
      out[attr.to_sym] = "vial.#{attr}"
    end
    out
  end

  def vial_fields
    [
      'specimen_code',
      'original_id',
      'specimen_institution',
      'fixative',
      'vacutainer'
    ]
  end
end
