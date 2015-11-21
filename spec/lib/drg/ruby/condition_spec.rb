require 'spec_helper'

describe DRG::Ruby::Condition do
  let(:sexp) do
    RubyParser.new.parse "return [] unless message[:verification_code_id]"
  end

  subject { described_class.new sexp }

  describe '#statement' do
    it 'parses the sexp condition into chunks' do
      expect(subject.statement).to eq 'return [] unless message[:verification_code_id]'
    end
  end

  describe '#return_value' do
    context 'when a single line expression' do
      it 'returns the correct return value' do
        expect(subject.return_value).to eq 'returns []'
      end
    end

    context 'when the code return value is nil' do
      let(:sexp) { RubyParser.new.parse "return unless message" }

      it 'says it returns nil' do
        expect(subject.return_value).to eq 'returns nil'
      end
    end
  end
end
