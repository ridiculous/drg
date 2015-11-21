require 'ruby_parser'
require 'delegate'

module DRG
  class Ruby
    # oh snap!!!
    DuckPuncher.punch! :Array

    autoload :Const, 'drg/ruby/const'
    autoload :Condition, 'drg/ruby/condition'
    autoload :Func, 'drg/ruby/func'
    autoload :ClassFunc, 'drg/ruby/class_func'
    autoload :InstanceFunc, 'drg/ruby/instance_func'
    autoload :Klass, 'drg/ruby/klass'

    attr_reader :sexp

    # @todo remove default (testing only)
    def initialize(file = FIXTURE_ROOT.join('report.rb'))
      @sexp = RubyParser.new.parse File.read(file)
    end

    def klass
      # @todo handle modules and whatnot
      @klass ||= Klass.new sexp
    end

    # @todo get modules included or extended by the subject
    def modules
    end
  end
end
