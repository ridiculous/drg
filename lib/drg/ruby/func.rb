class DRG::Ruby::Func < Struct.new(:sexp, :_private)
  alias private? _private

  def conditions
    DRG::Decorators::SexpDecorator.new(sexp).each_sexp_condition.map do |exp|
      DRG::Ruby::Condition.new(exp)
    end
  end

  # @note we drop(1) to get rid of :args (which should be the first item in the sexp)
  def map_args(_sexp = sexp, list = [])
    val = _sexp.first
    return list.drop(1) unless val
    case val
    when Symbol
      map_args(_sexp.drop(1), list << val)
    when Sexp
      map_args(_sexp.drop(1), list << val[1])
    else
      nil
    end
  end
end
