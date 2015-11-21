class DRG::Decorators::SexpDecorator < DelegateClass(Sexp)
  def each_sexp_condition
    return enum_for(__method__) unless block_given?
    each_sexp do |exp|
      next unless exp.is_a?(Sexp)
      if exp.first == :if or exp.enum_for(:deep_each).any? { |s| s.first == :if }
        yield exp
      end
    end
  end
end
