class DRG::Ruby::Func < Struct.new(:sexp, :_private)
  alias private? _private

  def conditions
    DRG::Decorators::SexpDecorator.new(sexp).each_sexp_condition.map &DRG::Ruby::Condition.method(:new)
  end

  def assignments
    nodes = find_assignments(sexp)
    sexp.find_nodes(:rescue).each do |node|
      node = node[1] if node[1].first == :block
      nodes.concat find_assignments(node)
    end
    nodes.map &DRG::Ruby::Assignment.method(:new)
  end

  def find_assignments(s_expression)
    s_expression.find_nodes(:op_asgn_or) + s_expression.find_nodes(:iasgn)
  end

  # @note we drop(1) to get rid of :args (which should be the first item in the sexp)
  # @note called from subclasses
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
