class DRG::Ruby::InstanceFunc < DRG::Ruby::Func
  def name
    sexp[1]
  end

  def args
    map_args(sexp[2]) if sexp[2].first == :args
  end

  def class?
    false
  end
end
