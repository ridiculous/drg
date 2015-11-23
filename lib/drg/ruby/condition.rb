require 'ruby2ruby'

class DRG::Ruby::Condition

  attr_reader :statement, :nested_conditions, :sexp

  def initialize(sexp)
    @sexp = sexp
    @statement = Ruby2Ruby.new.process(sexp.deep_clone)
    @nested_conditions = create_nested_conditions
  end

  def short_statement
    if @statement =~ /(unless|if)(.+)$/
      ($1 << $2).strip
    elsif @statement =~ /(.*?)\s+\?\s+/
      $1.strip
    end
  end

  def return_value
    edit find_return_value
  end

  def find_return_value
    if @statement =~ /\s+\?\s+(.*?)(:|$)/
      $1.strip
    elsif @statement[/then\n(.+)\nend/]
      $1.strip
    else
      @statement[/(.*?)(unless|if)/, 1].to_s.strip
    end
  end

  def edit(txt)
    txt.sub! /^return\s*/, 'returns '
    txt.sub! /^returns\s*$/, 'returns nil'
    if txt.split(/\s/).length == 1
      txt = "returns #{txt}"
    elsif txt.include?(' = ')
      txt = "assigns #{txt}"
    end
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

  #
  # Private
  #

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
