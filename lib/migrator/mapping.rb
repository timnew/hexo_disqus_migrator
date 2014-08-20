class Mapping
  attr_reader :migrator, :url, :host, :path, :local_path, :basename

  attr_accessor :new_url, :tags

  attr_accessor :output, :confident
  alias_method :output?, :output
  alias_method :confident?, :confident

  def new_path
    new_url.path
  end

  def new_path=(path)
    @new_url = URI(url.to_s)
    @new_url.path = URI.escape(path)
    @new_url
  end

  def new_local_path
    Migrator.local_path new_path
  end

  def new_basename
    File.basename new_path
  end

  def initialize(migrator, url_text)
    @migrator = migrator

    @url = URI(url_text)
    @host = url.host
    @path = url.path
    @local_path = Migrator.local_path path
    @basename = File.basename path

    @tags = []
    @new_url = @url
    @confident = true
    @output = false
  end

  def isnt?(tag)
    !tags.include?(tag)
  end
  alias_method :isnt, :isnt?

  def is?(tag)
    tags.include?(tag)
  end
  alias_method :is, :is?

  def execute
    migrator.migrate_mapping self
    self
  end
end