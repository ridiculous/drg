require 'ruby_parser'

class DRG::Ruby::Const
  CONSTANT_DEFS = { :class => :class, :module => :module, :cdecl => :class }

  # @param [Sexp] parser
  def initialize(parser)
    @parser = parser
  end

  def name(sexp = @parser, list = [])
    sexp = Array(sexp)
    if sexp[1].is_a?(Sexp) && sexp[1][0] == :colon2
      parts = sexp[1].to_a.flatten
      list.concat parts.drop(parts.size / 2)
    elsif CONSTANT_DEFS.key?(sexp[0])
      name(sexp.compact[2], list << sexp[1].to_s)
    end
    list.join('::')
  end

  def type(sexp = @parser, val = nil)
    sexp = Array(sexp)
    if sexp[1].is_a?(Sexp) && sexp[1][0] == :colon2
      val = sexp[0]
    elsif CONSTANT_DEFS.key?(sexp[0])
      val = type(sexp.compact[2], sexp[0])
    end
    CONSTANT_DEFS[val]
  end
end
