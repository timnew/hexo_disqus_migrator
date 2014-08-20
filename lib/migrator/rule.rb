
class Rule
  attr_reader :name, :auto_tag

  def initialize(name, auto_tag = true, &block)
    @name = name
    @auto_tag = auto_tag
    @match_blocks = []
    instance_eval &block
  end

  def apply(mapping)
    return false unless match?(mapping)
    act(mapping)
  end

  def setup_match(&block)
    @match_blocks << block
  end

  def match?(mapping)
    @match_blocks.all? {|b| b.call(mapping) }
  end

  def setup_action(&block)
    @action_block = block
  end

  def act(mapping)
    mapping.tags << name if auto_tag
    @action_block.call(mapping)
  end
end