require 'ruby2ruby'

class DRG::Ruby::Condition

  attr_reader :statement, :nested_conditions, :sexp

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

  def short_statement
    if @statement =~ /(unless|if)(.+)$/
      ($1 << $2).strip
    elsif @statement =~ /(.*?)\s+\?\s+/
      $1.strip
    end
  end

  def return_value
    if @statement =~ /\s+\?\s+(.*?)(:|$)/
      $1.strip
    else
      Translator.new.perform(@statement[/(.*?)(unless|if)/, 1].to_s.strip)
    end
  end

  class Translator
    def perform(txt)
      txt.sub! /^return\s*/, 'returns '
      txt.sub! /^returns\s*$/, 'returns nil'
      txt.strip
    end
  end
end
