require 'ruby2ruby'

class DRG::Ruby::Condition

  attr_reader :statement, :nested_conditions

  def initialize(sexp)
    @sexp = sexp
    @statement = Ruby2Ruby.new.process(sexp.deep_clone)
    @nested_conditions = []
    if sexp.drop(1).flatten.include?(:if)
      sexp.drop(1).deep_each do |exp|
        exp.find_nodes(:if).each { |node| @nested_conditions << self.class.new(node) }
      end
    end
  end
end
