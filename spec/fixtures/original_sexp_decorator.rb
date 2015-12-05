class OriginalSexpDecorator
  def each_sexp_condition
    return enum_for(__method__) unless block_given?
    yielded = []
    each_sexp do |exp|
      if exp.first == :if
        yield exp
        yielded << exp
      else
        nested_sexp = exp.enum_for(:deep_each).select { |s| s.first == :if }
        nested_sexp.each do |sexp|
          if yielded.find { |x| x.object_id == sexp.object_id or x.enum_for(:deep_each).find { |xx| xx.object_id == sexp.object_id } }.nil?
            yield sexp
            yielded << sexp
          end
        end
      end
    end
  end
end
