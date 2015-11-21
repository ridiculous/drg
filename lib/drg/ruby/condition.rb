require 'ruby2ruby'

class DRG::Ruby::Condition

  attr_reader :statement, :nested_conditions, :sexp

  def initialize(sexp)
    @sexp = sexp
    @statement = Ruby2Ruby.new.process(sexp.deep_clone)
    @nested_conditions = Set.new
    sexp.drop(1).flatten.include?(:if) && sexp.drop(1).deep_each do |exp|
      DRG::Decorators::SexpDecorator.new(exp).each_sexp_condition do |node|
        @nested_conditions << self.class.new(node)
      end
    end
    @nested_conditions = @nested_conditions.to_a
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
      translate @statement[/(.*?)(unless|if)/, 1].to_s.strip
    end
  end

  def translate(txt)
    txt.sub! /^return\s*/, 'returns '
    txt.sub! /^returns\s*$/, 'returns nil'
    txt.strip
  end

  #
  # Set related stuff
  #

  def eql?(other)
    hash == other.hash
  end

  def hash
    sexp.object_id
  end
end
