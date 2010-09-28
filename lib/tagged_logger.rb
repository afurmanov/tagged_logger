require 'delegate'
require 'facets/dictionary'

class TaggedLogger
  @rename_rules = Dictionary.new
  @tag_blocks = Dictionary.new

  class << self
    def reset
      @rename_rules = Dictionary.new
      @tag_blocks = Dictionary.new
      ObjectSpace.each_object(ClassSpecificLogger) { |obj| obj.detach }
      init
    end
    
    def rules(&block)
      add_logger_generator_in_Kernel
      instance_eval(&block)
    end
    
    def blocks_for(level, tag)
      blocks = []
      tag_aliases(tag) do |tag_alias|
        tag_blocks(level, tag_alias) do |tag_block|
          blocks << [tag_alias, tag_block]
        end
      end
      blocks
    end
    
    def init
      rules {}
    end
    
    def debug(what, where = {}, &block) output(:debug, what, where, &block) end
    def info(what, where = {}, &block) output(:info, what, where, &block) end
    def warn(what, where = {}, &block) output(:warn, what, where, &block) end
    def error(what, where = {}, &block) output(:error, what, where, &block) end
    def fatal(what, where = {}, &block) output(:fatal, what, where, &block) end
    
    def format(&block)
      @formatter = block
    end

    def formatter
      @formatter = lambda { |level, tag, message| "#{message}\n"} unless @formatter
      @formatter
    end

    def rename(renames)
      renames.each { |from, to| @rename_rules[tag_matcher(from)] = to }
    end
    
    private
    def output(level, what, where, &block)
      logger = where[:to]
      code = nil
      if logger
        #todo: hack - what about other logger classes?
        logger.formatter = lambda {|severity, datetime, progname, msg| "#{msg}"} if logger.is_a? Logger
        write = lambda { |level, tag, msg | logger.send(level, formatter.call(level, tag, msg)) }
        code = block ? lambda { |l,t,m| write.call(l,t,m); block.call(l,t,m) } : write
      elsif block
        code = block
      else
        raise ArgumentError "Should be called with block or :to => <logger>"
      end
      @tag_blocks[tag_matcher(what, level)] = code
    end
    
    class TagMatcher
      attr_reader :match_spec
      LEVELS = { :debug => 1, :info => 2, :warn => 3, :error => 4, :fatal => 5}
      
      def initialize(match_spec, level = nil)
        @level = level || :debug
        @match_spec = match_spec
      end
      
      def match?(tag, level = nil)
        return false if level && !above_treshold(level)
        self.class.match?(@match_spec, tag)
      end
      
      def above_treshold(level)
        LEVELS[@level] <= LEVELS[level]
      end
      
      def self.match?(spec, tag)
        t = tag.to_s
        result = case spec
                 when Regexp 
                   t =~ spec
                 when Class 
                   t == spec.name
                 when Array 
                   spec.any? {|s| match?(s, tag)}
                 else
                   spec.to_s == t
                 end
        return result if result
        self.match?(spec, tag.superclass) if tag.class == Class && tag.superclass != Class
      end
    end #TagMatcher
    
    def tag_matcher(tag, level = nil)
      TagMatcher.new(tag, level)
    end
    
    def tag_aliases(tag, &block)
      current_name = tag
      @rename_rules.each { |from, to| current_name = to if from.match?(tag) }
      block.call(current_name)
    end
    
    def tag_blocks(level, tag, &block)
      @tag_blocks.each do |matcher, block|
        yield block if matcher.match?(tag, level)
      end
    end
    
    def add_logger_generator_in_Kernel
      return if Kernel.respond_to?(:logger, true) #no harm
      Kernel.class_eval do
        def logger
          klass = self.class == Class ? self : self.class
          result = klass.class_eval do
            return @class_logger if @class_logger
            @class_logger = ClassSpecificLogger.new(klass)
            @class_logger
          end
          result
        end
      end
    end
    
  end # class methods
  
  class ClassSpecificLogger
    def eigenclass
      class <<self; self; end
    end

    def initialize(klass)
      @klass = klass
      [:debug, :warn, :info, :error, :fatal].each do |level|
        blocks = TaggedLogger.blocks_for(level, klass)
        eigenclass.send(:define_method, level) do |msg|
          blocks.each { |(tag_alias, block)| block.call(level, tag_alias, msg) }
        end
      end    
    end
    
    def detach
      @klass.class_eval do
        @class_logger = nil
      end
    end
  end
  
end
