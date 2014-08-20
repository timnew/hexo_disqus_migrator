class Migrator
  module ClassMethods

    ROOT_PATH = File.join(Dir.pwd, 'public')
    ROOT = Pathname.new ROOT_PATH
    POSTS_FOLDER = Pathname.new File.join(Dir.pwd, 'source/_posts')

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

    def root
      ROOT
    end

    def posts
      POSTS_FOLDER.each_child(false)
    end

    def local_path(path)
      Pathname.new File.join(ROOT_PATH, path)
    end

    def to_url(path)
      path[ROOT_PATH.length..-1]
    end

    def name_components(path)
      base_name = File.basename(path)
      base_name.split('-')
    end

    def verifier
      VERIFIER
    end

    def delegate_to_class(*names)
      names.each do |name|
        define_method name do |*args|
          self.class.send name, *args
        end
      end
    end
  end
end