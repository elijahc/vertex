require 'csv'
module Formatters
  def format_date(date)
    Chronic.parse(date).strftime('%m/%d/%Y %R')
  end

  def format_time_point(timepoint)
    # Fixed timepoint translation idioms
    idioms = [
      {:regex => Regexp.new(/Surgery/i), :out => "SURG"},
      {:regex => Regexp.new(/Pre\W*Trial\W*Diagnostic\W*Material/i), :out => "PTDM"},
      {:regex => Regexp.new(/Baseline/i), :out => "BSL"},
      {:regex => Regexp.new(/Step\s*(\d)/i),  :out => "STEP = :X"},
      {:regex => Regexp.new(/Cycle\s*(\d)/i), :out => "CYCLE = :X"},
      {:regex => Regexp.new(/Year\s*(\d)/i),  :out => "Y = :X"},
      {:regex => Regexp.new(/Month\s*(\d)/i), :out => "M = :X"},
      {:regex => Regexp.new(/Week\s*(\d)/i),  :out => "WK = :X"},
      {:regex => Regexp.new(/Day\s*(\d)/i),   :out => "D = :X"},
      {:regex => Regexp.new(/Hour\s*(\d)/i),  :out => "HR = :X"}
    ]

    # Split the timepoint string by its enumerator, usuallly a comma
    tokens = timepoint.split(/,/)

    # Iterate first by idioms, then by tokens, aggregating by idioms
    timepoint_attributes = []
    idioms.each do |idiom|
      tokens.each do |token|
        if token.match(idiom[:regex])
          timepoint_attributes << idiom[:out].gsub(':X', $1.to_s)
        end
      end
    end

    timepoint_attributes.compact.join(';')
  end

  def format_vacutainer(vacutainer)
    case vacutainer.to_s
    when /paxgene\s*(dna)/i
      return "PAXGENE #{$1}"
    when /N\/A/i
      return ''
    else
      return vacutainer.to_s
    end
  end

  def format_sample_modifiers(modifiers)
    bfs = ''
    modifiers.each do |k,v|
      unless v.empty?
        bfs << "#{k.to_s.capitalize} = #{v.to_s}, "
      end
    end
    bfs.chop.chop
  end

  def format_mat_type(type)
    case type.to_s
    when /^H\s*&*\s*E$/
      return 'SLDTS'
    when /^PLASMA$/i
      return 'PLS'
    when /^serum$/i
      return 'Blood Serum'
    when /^CELLS$/i
      return 'BUFRED'
    when /^Buffy Cells$/i
      return 'BUFRED'
    when /^DNA$/i
      return 'WB'
    when /stained slide/i
      return 'SLDTS'
    when /whole\sblood/i
      return 'WB'
    when /unstained slide/i
      return 'SLTDU'
    when /(BLK|ffpe)/i
      return 'BLK'
    else
      return type.to_s
    end
  end

  # Format Stain type
  def format_field_268(stain)
    case stain.to_s
    when 'N/A'
      return ''
    else
      return stain.to_s
    end
  end

  alias format_date_drawn format_date
  alias format_date_received format_date
end

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
      s = Specimen.new(options['model_options']).extend Formatters
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
        s.specimen_type = 'whole blood'
        #s.specimen_type   = csv['Surgical #'].downcase
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

    @specimens
  end

end
