require 'ruby2ruby'

class DRG::Ruby::Condition

  attr_reader :statement, :nested_conditions

  def initialize(sexp)
    @sexp = sexp
    @statement = Ruby2Ruby.new.process(sexp.deep_clone)
    @nested_conditions = []
    sexp.drop(1).flatten.include?(:if) && sexp.drop(1).deep_each do |exp|
      DRG::Decorators::SexpDecorator.new(exp).each_sexp_condition do |node|
        @nested_conditions << self.class.new(node)
      end
    end
  end
end
