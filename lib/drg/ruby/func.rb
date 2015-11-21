class DRG::Ruby::Func < Struct.new(:sexp, :_private)
  alias private? _private

  def conditions
    list = []
    sexp.each_sexp do |exp|
      next unless exp.is_a?(Sexp)
      if exp.first == :if or exp.flatten.include?(:if)
        list << DRG::Ruby::Condition.new(exp)
      end
    end
    list
  end

  # @note we drop(1) to get rid of :args (which should be the first item in the sexp)
  def map_args(_sexp = sexp, list = [])
    return list.drop(1) unless val = _sexp.shift
    case val
    when Symbol
      map_args(_sexp, list << val)
    when Sexp
      map_args(_sexp, list << val[1])
    else
      nil
    end
  end
end
