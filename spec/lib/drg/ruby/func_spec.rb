require 'spec_helper'

describe DRG::Ruby::Func do
  let(:klass) { DRG::Ruby.new(FIXTURE_ROOT.join('report.rb')).klass }
  let(:sexp) { klass.funcs.find { |x| x.name == :call }.sexp }
  let(:_private) { false }

  subject { described_class.new(sexp, _private) }

  describe '#conditions' do
    context 'when there is one simple condition' do
      it 'returns the ast rep of the condition' do
        cond = subject.conditions.map(&:nested_conditions).reject(&:empty?)
        expect(subject.conditions.length).to eq 3
        expect(cond.flatten.m(:statement)).to eq ["UserMailer.spam(user).deliver_now if user.wants_mail?"]
      end
    end
  end
end
