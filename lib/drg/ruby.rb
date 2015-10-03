require 'ruby_parser'

module DRG
  class Ruby
    attr_reader :parser

    def initialize(file)
      @parser = RubyParser.new.parse File.read(file)
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