require 'csv'
class Pipeline::Parser::E2108Parser
  include Pipeline::BSI::Models

  def parse(file_path, options={})

    @specimens = Array.new
    @failed_rows = Array.new

    @dummy_boxes = {}
    counter = 1

    pax_fluid_types = [
      'PAXgeneDNA',
      'PAXgeneRNA'
    ]

    generic_fluid_types = [
      'Cells',
      'DNA',
      'PBMC',
      'Plasma',
      'Serum'
    ]

    tissue_types = [
      'BLK',
      'BLK NODE',
      'BLK PRIMAR',
      'BLK TUMOR',
      'H & E',
      'H&E',
      'H&E PRIMAR',
      'PARACORE 2',
      'PARACORE 4',
      'UNS SLD PR',
      'Uns Slides',
      'UNSTN SLD',
      'UNSTN SLDS'
    ]

    CSV.foreach(file_path, :headers => true) do |csv|
      s = Specimen.new(options['model_options'])
      print "Reading row: #{counter}                 \r"

      #
      # Field mappings below
      #
      #######################

      # Global mappings independent of specimen file
      s.billing_method          = 'Purchase Order'
      s.label_status            = 'Barcoded'
      s.repos_id                = 'ECOG PCO'
      s.vial_status             = 'In'
      s.freezer                 = 'E2108'
      s.row                     = '1'
      s.col                     = 'A'

      # Global mappings from specimen file
      s.date_received           = csv['Sample Creation Date']
      s.date_drawn              = csv['Sample Date']
      s.study_id                = csv['Protocol #']
      s.subject_id              = csv['Sequence Number'].to_i.to_s
      s.current_label           = csv['PathCore ID'].to_i
      s.specimen_type           = csv['Sample Type Samples']
      s.specimen_code           = csv['Sample Code'].to_s
      s.timepoint               = csv['Timing of Collection']
      s.original_id             = csv['Internal Bar Code ID'].to_i
      s.specimen_institution    = csv['Specimen Institution Code']
      s.sample_modifiers        = "C = #{csv['Notes']};" if csv['Notes']

      # Special fields with no BSI equivalents
      num_aliquots              = csv['# of Aliquots'].to_i

      if pax_fluid_types.include?(s.specimen_type)

        s.vacutainer = s.specimen_type
        s.specimen_type   = csv['Surgical #'].downcase
        s.measurement_est = 'V'

      elsif generic_fluid_types.include?(s.specimen_type)

        s.vacutainer = csv['Surgical #']
        s.measurement_est = 'V'
        s.specimen_type = s.specimen_type.downcase
        case s.specimen_type.to_s
        when /dna/i
          s.specimen_type = 'whole blood'

        end

      elsif tissue_types.include?(s.specimen_type)

        # Coerce inputs into mappable types by the importer algorithm
        if s.specimen_type.match(/blk/i)
          s.specimen_type = 'ffpe'
        elsif s.specimen_type.match(/Uns Slides/i)
          s.specimen_type = 'unstained slide'
        elsif s.specimen_type.match(/(slide|$h.+e)/i)
          s.specimen_type = 'stained slide'
        end

        s.surgical_case_number = csv['Surgical #'].to_s
        s.fixative  = '10% NBF'
        s.block_status    = csv['Block Status']

        # Not sure how to assign these yet
        #s.surgical_case_part      = csv['surgery_number_part_normalized'].to_s
        #s.anatomical_site = csv['organ_site']
        #s.stain_type      = csv['histo_stain']
        #s.parent_id       = csv['parent_id_normalized']

      else

        # Not sure what falls in this category...
        # s.fixative                = csv['storage_additive']
        # s.vial_type               = csv['storage_container']
        @failed_rows << csv.to_hash
        next

      end

      num_aliquots.times do |i|
        dup = s.dup
        dup.current_label = "#{dup.current_label}-#{i+1}" if num_aliquots > 1
        @specimens << dup
      end

      counter += 1
    end #CSV.foreach

    if @failed_rows.first
      columns = @failed_rows.first.keys
      puts "Failed rows: #{@failed_rows.length}"
      s=CSV.generate do |csv|
        csv << columns
        @failed_rows.each do |x|
          csv << x.values
        end
      end
      File.write('./tmp/failed_rows.csv', s)
    end

    @specimens.uniq{|s| s.current_label}
  end

end
