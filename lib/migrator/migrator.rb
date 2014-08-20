require_relative 'migrator/rules'
require_relative  'migrator/class_methods'
require_relative  'migrator/reports'
require_relative  'migrator/outputs'

class Migrator
  extend Rules
  extend ClassMethods

  include Reports
  include Outputs

  delegate_to_class :root, :local_path, :to_url, :rules, :verifier

  attr_reader :mappings

  def initialize(csv_file)
    @mappings = CSV.open(csv_file)
    .map { |row| Mapping.new(self, row[0]) }
  end

  def migrate_mapping(mapping)
    rules.find do |rule|
      rule.apply(mapping)
    end
    verifier.apply(mapping)
  end

  def migrate
    mappings.map do |mapping|
      mapping.execute
    end
  end
end