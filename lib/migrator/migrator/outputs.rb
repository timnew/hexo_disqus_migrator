class Migrator
  module Outputs
    include Commander::Methods

    def write(type, filename, &filter)
      puts "Write #{type} to file #{filename}"
      CSV.open(filename, 'wb') do |csv|
        data = mappings.select(&filter)
        table_print data, "#{type} Entries", :basename, :tags
        progress data do |mapping|
          csv << [mapping.url.to_s, mapping.new_url.to_s]
        end
      end
      puts
    end

    def write_confident(filename)
      write('Confident', filename) do |m|
        m.output? && m.confident?
      end
    end

    def write_unconfident(filename)
      write('Unconfident', filename) do |m|
        m.output? && !m.confident?
      end
    end

    def write_invalid(filename)
      write('Invalid', filename) do |m|
        m.is(:invalid)
      end
    end

    def confirm_unconfidents
      mappings.select { |m| m.output? and !m.confident? }.each do |m|
        agreed = false
        until agreed do
          puts "Old: #{m.url}"
          puts "New: #{m.new_url}"
          agreed = agree('Okay to output?')

          unless agreed
            case choose("What to do?", :manual, :invalid, :cancel)
              when :manual
                m.new_url = ask('New Url:')
              when :invalid
                m.tags << :invalid
                m.output = false
                agreed = true
              when :cancel
                # do nothing
            end
          end
        end
      end
    end
  end
end