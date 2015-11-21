class DRG::Ruby::Klass < Struct.new(:sexp)
  def name
    DRG::Ruby::Const.new(sexp).name
  end

  def initialization_args
    funcs.find(-> { OpenStruct.new }) { |func| func.name == :initialize }.args
  end

  def func_by_name(name_as_symbol)
    funcs.find { |x| x.name == name_as_symbol }
  end

  def funcs
    marked_private = false
    sexp.map { |node|
      next unless node.is_a?(Sexp)
      case node.first
        when :defn
          DRG::Ruby::InstanceFunc.new(node, marked_private)
        when :defs
          DRG::Ruby::ClassFunc.new(node, marked_private)
        when :call
          marked_private ||= node[2] == :private
          nil
        else
          nil
      end
    }.compact
  end

  def instance_vars
  end

  def class_vars
  end
end
