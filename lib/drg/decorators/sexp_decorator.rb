class DRG::Decorators::SexpDecorator < DelegateClass(Sexp)
  def each_sexp_condition
    return enum_for(__method__) unless block_given?
    each_sexp do |exp|
      if exp.first == :if
        yield exp
      elsif nested_sexp = exp.enum_for(:deep_each).find { |s| s.first == :if }
        yield nested_sexp
      end
    end
  end
end
