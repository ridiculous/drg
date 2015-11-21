class DRG::Spec < DelegateClass(DRG::Ruby::Const)
  # = Class
  # generate a rspec file based on existing code

  def self.generate(file)
    spec = DRG::Spec.new(file)
    lines = []
    lines << %Q(describe #{spec.const} do)
    if spec.class?
      spec.initialization_args.each do |arg|
        lines << %Q(  let(:#{arg}) {})
      end
      lines << %Q()
      lines << %Q(  subject { described_class.new #{spec.initialization_args.join(', ')} })
    elsif spec.module?
      lines << %Q(  subject { Class.new { include #{spec.const} }.new })
    end

    lines << %Q()
    spec.funcs.reject(&:private?).each do |func|
      lines << %Q(  describe #{spec.quote("#{func.class? ? '.' : '#'}#{func.name}")} do)
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
    new_indent = indent + '  '
    contexts << %Q(#{indent}context #{quote(condition.short_statement)} do) << %Q(#{new_indent}before {})
    contexts << %Q(#{new_indent}it #{quote(condition.return_value)} do) << %Q(#{new_indent}end) unless condition.return_value.empty?
    if condition.nested_conditions.any?
      condition.nested_conditions.each { |nc| collect_contexts(nc, new_indent, contexts) }
    end
    contexts << %Q(#{indent}end) << %Q() # /context
    contexts << %Q(#{indent}context #{quote(negate(condition.short_statement))} do) << %Q(#{new_indent}before {})
    contexts << %Q(#{indent}end) << %Q()
    contexts
  end

  def quote(txt)
    if txt =~ /"/
      "%Q(#{txt})"
    else
      %Q("#{txt}")
    end
  end

  def negate(phrase)
    if phrase =~ /^(\s*)if/
      phrase.sub! /^#{$1}if/, 'if not'
    elsif phrase =~ /^(\s*)unless/
      phrase.sub! /^#{$1}unless/, 'if'
    else
      "not #{phrase}"
    end
  end
end
