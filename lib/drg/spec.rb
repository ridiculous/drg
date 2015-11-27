class DRG::Spec < DelegateClass(DRG::Ruby::Const)
  # = Class
  # generate a rspec file based on existing code

  def self.default_indent_size
    2
  end

  def self.generate(file)
    spec = new(file)
    return if spec.funcs.empty? # nothing to do
    lines = [%Q(require "spec_helper"), %Q(), %Q(describe #{spec.const} do)]
    if spec.class?
      spec.initialization_args.each do |arg|
        lines << %Q(  let(:#{arg.to_s.sub(/^[&*]/, '')}) {})
      end
      lines << %Q()
      lines << %Q(  subject { described_class.new #{spec.initialization_args.join(', ')} })
    elsif spec.module?
      lines << %Q(  subject { Class.new { include #{spec.const} }.new })
    end
    lines << %Q()
    spec.funcs.reject(&:private?).each do |func|
      lines << %Q(  describe #{spec.quote("#{func.class? ? '.' : '#'}#{func.name}")} do)
      func.assignments.each do |assignment|
        lines << %Q(    it #{spec.quote(assignment)} do) << %Q(    end)
      end
      func.conditions.each do |condition|
        lines.concat spec.collect_contexts(condition, '    ')
      end
      lines << %Q(  end) << %Q()
    end
    lines << %Q(end) << %Q()
    lines
  end

  attr_reader :ruby, :file

  def initialize(file)
    @file = file
    @ruby = DRG::Ruby.new(file)
    super @ruby.const
  end

  def const
    @const ||= begin
      require file
      Kernel.const_get(ruby.const.name)
    end
  end

  def collect_contexts(condition, indent = '', contexts = [])
    new_indent = indent + (' ' * self.class.default_indent_size)
    contexts << %Q(#{indent}context #{quote(tr(condition.short_statement))} do) << %Q(#{new_indent}before {})
    if should_print? condition.return_value
      contexts << %Q(#{new_indent}it #{quote(condition.return_value)} do) << %Q(#{new_indent}end)
    end
    if condition.nested_conditions.any?
      condition.nested_conditions.each { |nc| collect_contexts(nc, new_indent, contexts) }
    end
    contexts << %Q(#{indent}end) << %Q() # /context
    if condition.parts.empty?
      contexts << %Q(#{indent}context #{quote(tr(negate(condition.short_statement)))} do) << %Q(#{new_indent}before {})
      if should_print? condition.else_return_value
        contexts << %Q(#{new_indent}it #{quote(condition.else_return_value)} do) << %Q(#{new_indent}end)
      end
      contexts << %Q(#{indent}end)
    end
    condition.parts.each do |condition_part|
      contexts << %Q(#{indent}context #{quote(tr(condition_part.short_statement))} do) << %Q(#{new_indent}before {})
      contexts << %Q(#{new_indent}it #{quote(condition_part.return_value)} do) << %Q(#{new_indent}end)
      contexts << %Q(#{indent}end)
      if should_print? condition_part.else_return_value
        contexts << %Q(#{indent}context #{quote(tr(negate(condition_part.short_statement)))} do) << %Q(#{new_indent}before {})
        contexts << %Q(#{new_indent}it #{quote(condition_part.else_return_value)} do) << %Q(#{new_indent}end)
        contexts << %Q(#{indent}end)
      end
    end
    contexts
  end

  def quote(txt)
    txt = txt.to_s
    txt.strip!
    if txt =~ /"/
      "%Q[#{txt.gsub(/\#\{(.*?)\}/m, '\#{\1}')}]"
    else
      %Q("#{txt}")
    end
  end

  def negate(phrase)
    if phrase[/^unless /]
      phrase.sub /^unless /, 'if '
    else
      "not #{phrase}"
    end
  end

  def tr(phrase)
    phrase.sub! /^if /, 'when '
    phrase.sub! /^not if /, 'unless '
    phrase.sub! /^if not /, 'unless '
    phrase.sub! /then$/, ''
    if phrase !~ /^(when|unless|not)/
      phrase = "when #{phrase}"
    end
    phrase
  end

  # @description reject multiline statements, which means we messed up somewhere else, so let's hide that
  def should_print?(txt)
    !txt.empty? and txt !~ /\n/
  end
end
