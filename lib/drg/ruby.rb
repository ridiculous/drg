require 'ruby_parser'

module DRG
  class Ruby
    CONSTANT_DEFS = [:class, :module, :cdecl]

    attr_reader :parser

    def initialize(file)
      @parser = RubyParser.new.parse File.read(file)
    end

    def const_name(sexp = @parser, list = [])
      sexp = Array(sexp)
      if sexp[1].is_a?(Sexp) && sexp[1][0] == :colon2
        parts = sexp[1].to_a.flatten
        list.concat parts.drop(parts.size / 2)
      elsif CONSTANT_DEFS.include?(sexp[0])
        const_name(sexp.compact[2], list << sexp[1].to_s)
      end
      list.join('::')
    end

    def modules
    end

    class Klass < Struct.new(:sexp)

      def includes
      end

      def extends
      end

      def funcs
        sexp.find_nodes(:defn) + sexp.find_nodes(:defs)
      end

      def instance_vars
      end

      def class_vars
      end
    end

    class Func
      def name
      end

      def args
      end

      def private?
      end

      def conditions
      end
    end

    class Condition
    end
  end
end