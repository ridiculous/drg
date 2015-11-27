require 'spec_helper'

describe DRG::Ruby::Func do
  let(:klass) { DRG::Ruby.new(FIXTURE_ROOT.join('report.rb')).const }
  let(:sexp) { klass.funcs.find { |x| x.name == :call }.sexp }
  let(:_private) { false }

  subject { described_class.new(sexp, _private) }

  describe '#conditions' do
    context 'when there is one simple condition' do
      it 'returns the ast rep of the condition' do
        expect(subject.conditions.length).to eq 3
        expect(subject.conditions.first).to be_a(DRG::Ruby::Condition)
        expect(subject.conditions[1].short_statement).to eq '(1 == 2)'
        expect(subject.conditions[1].return_value).to eq 'returns 0'
      end
    end

    context 'when given multiple conditions' do
      let(:sexp) do
        RubyParser.new.parse <<-RUBY
          def load_device_stats
            detector = MobileDetect.new
            @device_stats = Hash.new(0)
            load_by_device.each do |row|
              if row[:read_at].present?
                if detector.mobile?(row[:device_received])
                  @device_stats[:mobile_received] += 1
                else
                  @device_stats[:desktop_received] += 1
                end
              end
              if detector.mobile?(row[:device_sent])
                @device_stats[:mobile_sent] += 1
              else
                @device_stats[:desktop_sent] += 1
              end
            end
          end
        RUBY
      end

      it 'returns all the conditions' do
        expect(subject.conditions.length).to eq 2
      end
    end
  end
end
