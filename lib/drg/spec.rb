class DRG::Spec
  # = Class
  #
  #
=begin
  spec = DRG::Spec.new(file)

describe #{spec.const.name} do
  if spec.class?
    subject { described_class.new #{spec.initialize_params.join(', ')} }
  else
    subject { Class.new { include #{spec.const.name} }.new }
  end

  spec.funcs.each do |func|
    describe '#{func.class? ? '.' : '#'}#{func.name}' do
      func.conditions do |condition|
        context 'when #{condition.statement}' do
          before {}
          if condition.nested_conditions?
            p
          end
        end
      end
    end
  end
end
=end
end
