class Migrator
  module ClassMethods

    ROOT_PATH = File.join(Dir.pwd, 'public')
    ROOT = Pathname.new ROOT_PATH
    POSTS_FOLDER = Pathname.new File.join(Dir.pwd, 'source/_posts')



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

    def delegate_to_class(*names)
      names.each do |name|
        define_method name do |*args|
          self.class.send name, *args
        end
      end
    end
  end
end