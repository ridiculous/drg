require 'ruby_parser'

class DRG::Ruby::Const
  CLASS_MOD_DEFS = { class: :class, module: :module }
  CONSTANT_DEFS = { cdecl: :class }.merge CLASS_MOD_DEFS

  attr_reader :sexp

  # @param [Sexp] sexp
  def initialize(sexp)
    sexp = sexp[2] if sexp[0] == :block
    @sexp = sexp
  end

  # s(:module, :Admin, s(:class, :Super, nil, s(:class, :UsersController, s(:colon3, :ApplicationController), s(:defn, :name, s(:args)
  # s(:class, :Report, nil, s(:cdecl, :DEFAULT_TZ, s(:str, "UTC")), s(:defs, s(:self), :enqueue,
  def name(sexp = @sexp, list = [])
    sexp = Array(sexp)
    if sexp[1].is_a?(Sexp) && sexp[1][0] == :colon2
      parts = sexp[1].to_a.flatten
      list.concat parts.drop(parts.size / 2)
    elsif CONSTANT_DEFS.key?(sexp[0])
      list << sexp[1].to_s
      # recurse unless the second element is nil, which indicates it's the end of the class/module definition
      if !sexp[2].nil? || (sexp[3].is_a?(Sexp) and CLASS_MOD_DEFS.key?(sexp[3].first))
        name(sexp.compact[2], list)
      end
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
    @funcs ||= load_funcs.flatten
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

  def load_funcs(sexp_list = sexp)
    marked_private = false
    sexp_list.map { |node|
      next unless node.is_a?(Sexp)
      case node.first
      when :defn
        DRG::Ruby::InstanceFunc.new(node, marked_private)
      when :defs
        DRG::Ruby::ClassFunc.new(node, marked_private)
      when :call
        marked_private ||= node[2] == :private
        nil
      when ->(name) { CONSTANT_DEFS.key?(name) }
        # @note handle diz kind stuff:
        #   s(:class, :VerificationCode, nil, s(:defs, s(:self), :find, s(:args, :*)))
        # and
        #   s(:module, :ConditionParsers, s(:class, :ReturnValue, ...))
        # and
        #   s(:class, :NotificationPresenter, nil, s(:call, nil, :extend, s(:const, :Forwardable)), s(:call, nil, :attr_reader, ...))
        load_funcs(node.compact.drop(2))
      else
        # @todo uncomment with logger at debug level
        #   puts "got #{__method__} with #{node.first} and don't know how to handle it"
        # @note :const seems to indicate module inclusion/extension
        nil
      end
    }.compact
  end
end
