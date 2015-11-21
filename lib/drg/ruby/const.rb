require 'ruby_parser'

class DRG::Ruby::Const
  CONSTANT_DEFS = { :class => :class, :module => :module, :cdecl => :class }

  attr_reader :sexp

  # @param [Sexp] sexp
  def initialize(sexp)
    sexp = sexp.select { |x| x.is_a?(Array) }.last if sexp[0] == :block
    @sexp = sexp
  end

  def name(sexp = @sexp, list = [])
    sexp = Array(sexp)
    if sexp[1].is_a?(Sexp) && sexp[1][0] == :colon2
      parts = sexp[1].to_a.flatten
      list.concat parts.drop(parts.size / 2)
    elsif CONSTANT_DEFS.key?(sexp[0])
      name(sexp.compact[2], list << sexp[1].to_s)
    end
    list.join('::')
  end

  def type(sexp = @sexp, val = nil)
    sexp = Array(sexp)
    if sexp[1].is_a?(Sexp) && sexp[1][0] == :colon2
      val = sexp[0]
    elsif CONSTANT_DEFS.key?(sexp[0])
      val = type(sexp.compact[2], sexp[0])
    end
    CONSTANT_DEFS[val]
  end

  def initialization_args
    funcs.find(-> { OpenStruct.new }) { |func| func.name == :initialize }.args.to_a
  end

  def func_by_name(name_as_symbol)
    funcs.find { |x| x.name == name_as_symbol }
  end

  def funcs
    @funcs ||= load_funkyness
  end

  def class?
    type == :class
  end

  def module?
    type == :module
  end

  # @todo
  def instance_vars
  end

  # @todo
  def class_vars
  end

  private

  def load_funkyness
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
end
