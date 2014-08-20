class Migrator
  module Reports
    def table_print(data, title, *columns)
      table = Terminal::Table.new do |t|
        t.headings = columns
        t.title = title
        data.each do |mapping|
          t.add_row columns.map { |c| mapping.send(c) }
        end
      end

      puts table
      puts

      table
    end

    def overview_report
      table_print mappings, 'Overview', :basename, :host, :tags, :output?, :confident?
    end

    def unconfident_report
      data = mappings.select { |m| !m.confident? }
      table_print data, 'Unconfident', :url, :new_url
    end

    def excluded_report
      data = mappings.select { |m| !m.output? }
      table_print data, 'Excluded', :basename, :host, :tags
    end

    def invalid_report
      data = mappings.select { |m| m.is?(:invalid) }
      table_print data, 'Invalid', :url, :tags, :new_path
    end
  end
end