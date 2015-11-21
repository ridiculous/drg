require 'spec_helper'

describe DRG::Ruby::ClassFunc do
  let(:sexp) { DRG::Ruby.new(FIXTURE_ROOT.join('report.rb')).const.funcs.find(&:class?).sexp }
  let(:_private) { false }

  subject { described_class.new(sexp, _private) }

  describe '#name' do
    it 'returns the name of our method as a symbol' do
      expect(subject.name).to eq :enqueue
    end
  end

  describe '#args' do
    it 'returns the names the arguments for the method' do
      expect(subject.args).to eq [:verification_code]
    end
  end

  describe '#class?' do
    it 'returns true' do
      expect(subject).to be_class
    end
  end
end
