class DRG::Ruby::ClassFunc < DRG::Ruby::Func
  def name
    sexp[2]
  end

  def args
    map_args(sexp[3]) if sexp[3].first == :args
  end

  def class?
    true
  end
end
