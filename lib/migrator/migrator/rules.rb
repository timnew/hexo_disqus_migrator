class Migrator
  module Rules
    VERIFIER = Rule.new(:valid_checker, false) do
      setup_match { |m| m.isnt?(:ignored) }
      setup_action do |m|
        local_file = Migrator.local_path m.new_path

        if local_file.exist?
          m.tags << :valid
        else
          m.tags << :invalid
          m.output = false
        end
      end
    end

    FIX_CHECKER = Rule.new(:fix_checker, false) do
      setup_match { |m| m.is?(:broken) }
      setup_match { |m| m.isnt?(:fixed) }
      setup_match { |m| Migrator.local_path(m.new_path).exist? }
      setup_action do |m|
        m.tags << :fixed
        true
      end
    end

    def verifier
      VERIFIER
    end

    def fix_checker
      FIX_CHECKER
    end

    RULES = []

    def rules
      RULES
    end

    def self.rule(*args, &block)
      RULES << Rule.new(*args, &block)
    end

    rule(:ignored) do
      setup_match { |m| m.host == 'localhost' }
      setup_action do |m|
        m.output = false
        true
      end
    end

    rule(:update_host) do
      setup_match { |m| m.host != 'timnew.me' }
      setup_action do |m|
        m.output = true
        false
      end
    end

    rule(:normalize_url) do
      regex = /\/\//
      setup_match { |m| m.path =~ regex }
      setup_action do |m|
        m.output = true
        m.new_path = m.new_path.gsub regex, '/'
        false
      end
    end

    rule(:broken) do
      setup_match { |m| !m.new_local_path.exist? }
      setup_action do |m|
        m.output = false
        false
      end
    end

    rule(:fix_root) do
      setup_match { |m| m.is?(:broken) }
      setup_match do |m|
        !m.new_path.start_with?('/blog/')
      end

      setup_action do |m|
        m.new_path = m.new_path.gsub(/^\/[^\/]+\//, '/blog/')
        m.output = true
        Migrator.fix_checker.apply(m)
      end
    end

    rule(:time_stamp_url) do
      setup_match { |m| m.is?(:broken) }
      setup_match { |m| m.isnt?(:fixed) }

      setup_match { |m| m.new_basename.match(/^\d\d\d\d-\d\d-\d\d-/) }

      setup_action do |m|
        m.new_path = m.new_path.sub(/\/\d\d\d\d-\d\d-\d\d-/, '/')
        m.output = true
        Migrator.fix_checker.apply(m)
      end
    end

    rule(:time_stamp_path, false) do
      setup_match { |m| m.is?(:broken) }
      setup_match { |m| m.isnt?(:fixed) }
      setup_action do |m|
        pattern = "*-#{m.basename}.md"
        local_file = Migrator.posts.find { |f| f.fnmatch? pattern }

        if local_file.nil?
          false
        else
          m.tags << name
          timestamp_path= local_file.basename.to_s.match(/^(\d\d\d\d-\d\d-\d\d)/).to_s.gsub(/-/, '/')

          m.output = true
          m.new_path = File.join('/', 'public', 'timestamp_path', m.basename.to_s)
          Migrator.fix_checker.apply(m)
        end
      end
    end

    rule(:auto_rename) do
      setup_match { |m| m.is?(:broken) }
      setup_match { |m| m.isnt?(:fixed) }

      setup_match do |m|
        parent = m.local_path.parent
        parent.exist? and parent.children.length == 1
      end

      setup_action do |m|
        m.new_path = Migrator.to_url m.local_path.parent.children.first.to_s
        m.confident = false
        m.output = true
        Migrator.fix_checker.apply(m)
      end
    end

    rule(:fuzzy_rename) do
      setup_match { |m| m.tags.include?(:broken) }

      setup_match do |m|
        parent = m.local_path.parent
        parent.exist?
      end

      setup_action do |m|
        components = Migrator.name_components(m.new_path)

        fuzzy_matched = m.local_path.parent
        .each_child
        .sort_by do |candidate|
          candidate_components = Migrator.name_components(candidate.to_s)
          result = components & candidate_components
          result.length
        end
        .reverse
        .first

        m.new_path = Migrator.to_url fuzzy_matched.to_s

        m.confident = false
        m.output = true
        Migrator.fix_checker.apply(m)
      end
    end

  end
end
