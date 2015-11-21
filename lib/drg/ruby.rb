require 'ruby_parser'
require 'delegate'

module DRG
  class Ruby
    autoload :Const, 'drg/ruby/const'
    autoload :Condition, 'drg/ruby/condition'
    autoload :Func, 'drg/ruby/func'
    autoload :ClassFunc, 'drg/ruby/class_func'
    autoload :InstanceFunc, 'drg/ruby/instance_func'

    attr_reader :sexp, :const

    # @param [Pathname] file
    def initialize(file)
      file = "#{file}.rb" if file.extname.empty?
      @sexp = RubyParser.new.parse File.read(file)
      @const = DRG::Ruby::Const.new(sexp)
    end
  end
end
