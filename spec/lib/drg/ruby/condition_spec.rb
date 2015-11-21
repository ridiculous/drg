require 'spec_helper'

describe DRG::Ruby::Condition do
  let(:sexp) do
    RubyParser.new.parse <<-RUBY
      return [] unless message[:verification_code_id]
    RUBY
  end

  subject { described_class.new sexp }

  describe '#statement' do
    it 'parses the sexp condition into chunks' do
      expect(subject.statement).to eq 'return [] unless message[:verification_code_id]'
    end
  end
end
