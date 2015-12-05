require 'ruby_parser'
require 'delegate'

module DRG
  class Ruby
    autoload :Const, 'drg/ruby/const'
    autoload :Condition, 'drg/ruby/condition'
    autoload :ConditionExhibit, 'drg/ruby/condition_exhibit'
    autoload :Func, 'drg/ruby/func'
    autoload :ClassFunc, 'drg/ruby/class_func'
    autoload :InstanceFunc, 'drg/ruby/instance_func'
    autoload :Assignment, 'drg/ruby/assignment'
    autoload :SexpDecorator, 'drg/ruby/sexp_decorator'

    attr_reader :sexp, :const

    # @param [Pathname, String] file
    def initialize(file)
      @sexp = RubyParser.new.parse File.read(file)
      @const = DRG::Ruby::Const.new(sexp)
    end
  end
end
