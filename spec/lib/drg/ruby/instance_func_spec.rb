require 'spec_helper'

describe DRG::Ruby::InstanceFunc do
  let(:klass) { DRG::Ruby.new(FIXTURE_ROOT.join('report.rb')).const }
  let(:sexp) { klass.funcs.reject(&:class?).last.sexp }
  let(:_private) { false }

  subject { described_class.new(sexp, _private) }

  describe '#name' do
    it 'returns the name of our method as a symbol' do
      expect(subject.name).to eq :less_secret_stuff
    end
  end

  describe '#args' do
    it 'returns an empty array' do
      expect(subject.args).to eq []
    end

    context 'when the method has args' do
      let(:sexp) { klass.funcs.find { |x| x.name == :map_args }.sexp }

      it 'returns the names the arguments for the method' do
        expect(subject.args).to eq [:sexp, :list]
      end
    end
  end

  describe '#class?' do
    it 'returns false' do
      expect(subject).to_not be_class
    end
  end
end
