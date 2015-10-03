require 'ruby_parser'

module DRG
  class Ruby
    class Const
      CONSTANT_DEFS = [:class, :module, :cdecl]

      def initialize(file)
        @parser = RubyParser.new.parse File.read(file)
      end

      def name(sexp = @parser, list = [])
        sexp = Array(sexp)
        if sexp[1].is_a?(Sexp) && sexp[1][0] == :colon2
          parts = sexp[1].to_a.flatten
          list.concat parts.drop(parts.size / 2)
        elsif CONSTANT_DEFS.include?(sexp[0])
          name(sexp.compact[2], list << sexp[1].to_s)
        end
        list.join('::')
      end
    end
  end
end
