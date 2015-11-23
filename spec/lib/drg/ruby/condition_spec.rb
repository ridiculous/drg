require 'spec_helper'

describe DRG::Ruby::Condition do
  let(:sexp) do
    RubyParser.new.parse "return [] unless message[:verification_code_id]"
  end

  subject { described_class.new sexp }

  describe '#initialize' do
    describe 'nested conditions' do
      context 'when there are no nested conditions' do
        it 'returns an empty array' do
          expect(subject.nested_conditions).to eq []
        end
      end

      context 'when there are nested conditions' do
        let(:sexp) do
          RubyParser.new.parse '
          def tab_link_to(*args)
            link_to(*args, class: "#{\'active\' if args.pop}")
          end
          '
        end

        it 'returns a list of nested conditions' do
          expect(subject.nested_conditions.length).to eq 1
          expect(subject.nested_conditions.first.statement).to eq "\"active\" if args.pop"
          expect(subject.nested_conditions.first.nested_conditions).to eq []
        end
      end
    end
  end

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

    context 'when reading a longer if statement' do
      let(:sexp) { RubyParser.new.parse %Q[return [] unless message[:verification_code_id] or message["verification_code_id"]] }

      it 'returns the correct value' do
        expect(subject.return_value).to eq 'returns []'
      end
    end

    context 'returning an array' do
      let(:sexp) {
        RubyParser.new.parse '
if file.extname.empty?
  ["#{file}.rb"]
else
  [file]
end
'
      }

      it 'returns the correct value' do
        expect(subject.return_value).to eq %Q(returns ([\"\#{file}.rb\"]))
      end
    end
  end
end
