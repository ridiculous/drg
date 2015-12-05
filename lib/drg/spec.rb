class DRG::Spec < DelegateClass(DRG::Ruby::Const)
  # = Class
  # generate a rspec file based on existing code

  def self.default_indent_size
    2
  end

  attr_reader :ruby, :file

  def initialize(file)
    @file = file
    @ruby = DRG::Ruby.new(file)
    super @ruby.const
  end

  def const
    @const ||= Kernel.const_get(ruby.const.name)
  end

  def perform
    indent = (' ' * self.class.default_indent_size)
    second_indent = indent * self.class.default_indent_size
    lines = [%Q(require "spec_helper"), %Q(), %Q(describe #{const} do)]
    if class?
      initialization_args.each do |arg|
        lines << %Q(#{indent}let(:#{arg.to_s.sub(/^[&*]/, '')}) {})
      end
      lines << %Q()
      lines << %Q(#{indent}subject { described_class.new #{initialization_args.join(', ')} })
    elsif module?
      lines << %Q(#{indent}subject { Class.new { include #{const} }.new })
    end
    lines << %Q()
    funcs.reject(&:private?).each do |func|
      lines << %Q(#{indent}describe "#{func.class? ? '.' : '#'}#{func.name}" do)
      func.assignments.each do |assignment|
        lines << %Q(#{second_indent}it "#{assignment}" do) << %Q(#{second_indent}end)
      end
      lines << %Q() if func.conditions.any? and func.assignments.any?
      func.conditions.each do |condition|
        lines.concat DRG::Decorators::ConditionDecorator.new(condition, second_indent).collect_contexts
      end
      lines << %Q(#{indent}end) << %Q()
    end
    lines << %Q(end) << %Q()
    lines
  end
end
