require 'ruby2ruby'

class DRG::Ruby::Condition

  module SetComparison
    def eql?(other)
      hash == other.hash
    end

    def hash
      sexp.object_id
    end
  end

  include SetComparison

  attr_reader :statement, :nested_conditions, :sexp, :parts, :unless_found

  def initialize(sexp)
    @sexp = sexp
    @statement = Ruby2Ruby.new.process(sexp.deep_clone)
    @nested_conditions = create_nested_conditions
    @parts = load_parts
  end

  # @note When the 2nd index is nil this will be an unless statement
  def short_statement
    "#{'unless ' if sexp[2].nil?}#{Ruby2Ruby.new.process(sexp[1].clone!)}"
  end

  def if_return_value
    edit Ruby2Ruby.new.process(find_if_return_value.clone!)
  end

  def else_return_value
    edit Ruby2Ruby.new.process(find_else_return_val.clone!)
  end

  #
  # Private
  #

  def find_if_return_value
    if sexp[2].nil?
      sexp.last
    elsif sexp[2].first == :if
      nil
    elsif sexp[2].first == :block
      sexp[2].last
    elsif sexp[2].first == :rescue
      sexp[2][1].last
    else
      sexp[2]
    end
  end

  def find_else_return_val
    if sexp.compact[3].nil?
      nil
    elsif sexp[3].first == :block
      sexp[3].last
    elsif sexp[3].first == :if
      nil
    else
      sexp[3]
    end
  end

  def edit(txt)
    txt = txt.to_s
    txt.sub! /^return\b/, 'returns'
    txt.sub! /^returns\s*$/, 'returns nil'
    if txt.include?(' = ')
      txt = "assigns #{txt}"
    elsif !txt.empty? and txt !~ /^return/
      txt = "returns #{txt.strip}"
    end
    txt.strip
  end

  # @description handles elsif
  def load_parts
    condition_parts = Set.new
    sexp.each_sexp do |s|
      if s.first == :if
        condition_parts << self.class.new(s)
      end
    end
    condition_parts.to_a
  end

  def create_nested_conditions
    nc = Set.new
    s = sexp.drop(1)
    s.flatten.include?(:if) && s.deep_each do |exp|
      DRG::Decorators::SexpDecorator.new(exp).each_sexp_condition do |node|
        nc << self.class.new(node)
      end
    end
    nc.to_a
  end
end
