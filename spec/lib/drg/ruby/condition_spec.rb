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
    end
  end

  describe '#statement' do
    it 'parses the sexp condition into chunks' do
      expect(subject.statement).to eq 'return [] unless message[:verification_code_id]'
    end
  end

  describe '#short_statement' do
    context 'when a single line expression with unless modifier' do
      it 'returns an accurate summary of the condition' do
        expect(subject.short_statement).to eq 'unless message[:verification_code_id]'
      end
    end
  end

  describe '#return_value' do
    context 'when a single line expression with unless modifier' do
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
      let(:sexp) do
        RubyParser.new.parse '
if file.extname.empty?
  ["#{file}.rb"]
else
  [file]
end
'
      end

      it 'returns the correct value' do
        expect(subject.return_value).to eq %Q(returns [\"\#{file}.rb\"])
      end
    end

    context 'multiline if/elsif/else' do
      let(:sexp) {
        s(:if, s(:call, s(:call, nil, :report), :save), s(:block, s(:if, s(:call, s(:call, nil, :user), :wants_mail?), s(:call, s(:call, s(:const, :UserMailer), :spam, s(:call, nil, :user)), :deliver_now), nil), s(:call, s(:call, nil, :report), :perform)), s(:if, s(:call, s(:call, nil, :report), :save!), s(:call, s(:call, nil, :report), :force_perform), s(:call, s(:call, nil, :report), :failure)))
      }

      it 'returns the correct return value' do
        expect(subject.return_value).to eq "returns report.perform"
      end
    end

    context 'when the statement contains a begin/end block' do
      let(:sexp) do
        RubyParser.new.parse <<-RUBY
          if user.cards.map(&:fingerprint).exclude?(payment.fingerprint)
            begin
              log 'card not found, creating it ...'
              user.cards.create(card: payment.token)
              log 'done'
              log 'reloading cards ...'
              user.cards!
            rescue Stripe::InvalidRequestError => e
              log "Failed to create card with token: \#{payment.token}. \#{e.message}"
            end
          end
        RUBY
      end

      it 'returns the last line of the begin' do
        expect(subject.return_value).to eq 'returns user.cards!'
      end
    end

    context 'when given a condition with only a nested condition' do
      let(:sexp) do
        RubyParser.new.parse <<-RUBY
        if row[:read_at].present?
          if detector.mobile?(row[:device_received])
            @device_stats[:mobile_received] += 1
          else
            @device_stats[:desktop_received] += 1
          end
        end
        RUBY
      end

      it 'returns an empty string' do
        expect(subject.return_value).to eq ''
      end
    end
  end

  describe '#else_return_value' do
    context 'when given an if/else statement' do
      let(:sexp) do
        s(:if, s(:call, nil, :some_condition), s(:call, s(:call, nil, :some_condition), :call, s(:call, nil, :env)), s(:call, s(:call, nil, :fallback), :call, s(:call, nil, :env)))
      end

      it 'returns the return value of the else statement' do
        expect(subject.else_return_value).to eq 'returns fallback.call(env)'
      end
    end

    context 'when if statement with no else' do
      it 'returns an empty string' do
        expect(subject.else_return_value).to eq ''
      end
    end

    context 'when given a long if/elsif/else' do
      let(:sexp) do
        RubyParser.new.parse <<-RUBY
          if coupon.nil?
            fail Error, "Couldn't find the coupon"
          elsif coupon.cannot_use?
            fail Error, 'Coupon has been used up'
          elsif coupon.expired?
            fail Error, 'Coupon has expired'
          elsif coupon.inactive?
            fail Error, 'Coupon is not activated'
          else
            @item = coupon
          end
        RUBY
      end

      it 'returns the correct parts' do
        expect(subject.else_return_value).to eq ''
      end
    end
  end

  describe '#parts' do
    context 'when simple if/else' do
      let(:sexp) do
        s(:if, s(:call, s(:call, nil, :me), :==, s(:str, "ryan")), s(:str, "that's me!"), s(:str, "who dat?"))
      end

      it 'returns an empty array' do
        expect(subject.parts).to eq []
      end
    end

    context 'when multiline if/else' do
      let(:sexp) do
        s(:if, s(:call, s(:call, nil, :me), :==, s(:str, "ryan")), s(:block, s(:iasgn, :@msg, s(:str, "that's me!")), s(:call, s(:ivar, :@msg), :upcase)), s(:block, s(:iasgn, :@msg, s(:str, "who dat?")), s(:call, s(:ivar, :@msg), :downcase)))
      end

      it 'returns an empty array' do
        expect(subject.parts).to eq []
      end
    end

    context 'when if/elsif/else' do
      let(:sexp) do
        s(:if,
          s(:or,
            s(:and,
              s(:call,
                s(:call, nil, :me), :==, s(:str, "ryan")),
              s(:call, s(:call, nil, :you), :==, s(:str, "foo"))
            ),
            s(:call, nil, :dude)
          ),
          s(:if,
            s(:call,
              s(:call, nil, :dude), :==, s(:str, "1")
            ),
            s(:call, nil, :call_foo, s(:call, nil, :dude)),
            s(:call, nil, :call_foo, s(:call, nil, :you))
          ),
          s(:if,
            s(:call,
              s(:call, nil, :you), :==, s(:str, "bar")
            ),
            s(:call, nil, :call_bar, s(:call, nil, :you)),
            s(:block,
              s(:call, nil, :puts, s(:str, "don't know who to call")),
              s(:return, s(:str, "wut"))
            )
          )
        )
      end

      it 'returns the parts of the condition' do
        expect(subject.parts.length).to eq 2
        expect(subject.parts.map(&:short_statement)).to eq ['(dude == "1")', '(you == "bar")']
        expect(subject.parts.map(&:return_value)).to eq ['returns call_foo(dude)', 'returns call_bar(you)']
        expect(subject.parts.map(&:else_return_value)).to eq ['returns call_foo(you)', 'returns "wut"']
      end
    end
  end
end
