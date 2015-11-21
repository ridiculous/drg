module DRG
  class FileContext
    # = Class
    # First attempt at reading ruby files. It was a pipe dream. See DRG::Ruby for the real stuff ;)
    #

    attr_writer :lines

    def initialize
      @lines = Set.new
      @is_private = false
    end

    def add(raw_line, index = 0)
      line_number = index + 1
      line = parse_line(raw_line, line_number)
      @lines << line
      line
    end

    def inspect
      %Q(#<DRG::FileContext:#{object_id} @lines=#{@lines.count}>, @is_private=false, @is_protected=false>)
    end

    def lines
      @lines.to_a
    end

=begin

def set_name *args
def get_name
def [](other)
def +
def -
def <=>
def /
def eql?

=end
    def parse_line(line, line_number)
      case line.to_s.chomp.strip
      when /\A(=begin|=end)/
        nil
      when /class\s+([A-Z]+\w*)/
        return ClassDef.new($1, line_number)
      when /module\s+([A-Z]+\w*)/
        return ModuleDef.new($1, line_number)
      when /def self\.([a-z0-9\[\]_+-<=>?]+)\s*\(?/
        # @todo check if within class << self
        return ClassMethodDef.new($1, line_number, current_class_or_module, @is_private)
      when /def ([a-z0-9\[\]_+-<=>?]+)\s*\(?/
        return InstanceMethodDef.new($1, line_number, current_class_or_module, @is_private)
      when /(.+)\s*(do|\{)(.*)(\}|end)/
        return BlockDef.new($1, $2, $3, line_number, $4)
      when /(.+)\s*(do|\{)(.*)/
        return BlockDef.new($1, $2, $3, line_number)
      when /#*\s*(private|protected)\b/i
        @is_private = true
      when /#*\s*public[\s\n]+/i
        @is_private = false
      when /\A(end|\})\b/i
        close_current_definition unless current_definition.method?
      else
        nil
      end
      NullLine.new(line)
    end

    def current_definition
      lines.reverse.detect { |line| line.open? } || Definition.new
    end

    def close_current_definition
      current_definition.close
    end

    def current_class_or_module
      current_definition = lines.reverse.detect { |line| line.open? && (line.class? || line.mod?) }
      current_definition && current_definition.name
    end

    def classes
      lines.select { |line| line.class? }
    end

    def modules
      lines.select { |line| line.mod? }
    end

    def blocks
      lines.select { |line| line.block? }
    end

    def methods
      lines.select { |line| line.method? }
    end

    def last_method
      lines.reverse.detect { |line| line.method? }
    end

    def last_class
      lines.reverse.detect { |line| line.class? }
    end

    module NullDefinition
      def class?
        false
      end

      def mod?
        false
      end

      def method?
        false
      end

      def block?
        false
      end
    end

    class NullLine < DelegateClass(String)
      include NullDefinition

      def eql?(*)
        false
      end

      def open?
        false
      end
    end

    class Definition < Object
      include NullDefinition
      attr_accessor :open, :name, :line_number

      def initialize(name = nil, line_number = nil, open = true)
        @name, @line_number, @open = name, line_number.to_i, open
      end

      def inspect
        %Q(#<#{self.class.name} #{instance_variables.map { |i| %Q(#{i}="#{instance_variable_get(i)}") }.join(', ')}>)
      end

      alias to_s inspect

      def eql?(other)
        @name == other.name && @line_number == other.line_number
      end

      def close
        @open = false
      end

      alias open? open
      alias hash line_number
    end

    class MethodDefinition < Definition
      attr_accessor :class_name, :is_private

      def initialize(name, line_number, class_name, is_private)
        super(name, line_number, false)
        @class_name, @is_private = class_name, is_private
      end

      def method?
        true
      end
    end

    class ClassDef < Definition
      def class?
        true
      end
    end

    class ModuleDef < Definition
      def mod?
        true
      end
    end

    class ClassMethodDef < MethodDefinition
    end

    class InstanceMethodDef < MethodDefinition
    end

    class BlockDef < Definition
      def initialize(name, body, opener, line_number, closer = nil)
        super(name, line_number, !!closer) # not open if closer present (single line block)
        @body, @opener, @closer, = body, opener, closer
      end

      def block?
        true
      end
    end
  end
end
