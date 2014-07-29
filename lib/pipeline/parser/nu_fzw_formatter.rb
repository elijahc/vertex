module Pipeline
  module BSI
    module Models
      module Formatters
        def format(specimen)
          # Data expected to be in bsi formatted hash format
          specimen.each do |k,v|
            type = k.match(/\.(.+_.+|.+)$/)[1]
            begin
              specimen[k] = send("format_#{type}".to_sym, v)
            rescue NoMethodError => e
              # No formatter defined use passed value as formatted
              specimen[k] = v.to_s
            end
          end
          specimen
        end

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
