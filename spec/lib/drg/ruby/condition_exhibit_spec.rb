require 'spec_helper'

describe DRG::Ruby::ConditionExhibit do
  let(:sexp) { RubyParser.new.parse "return [] unless message[:verification_code_id]" }
  let(:condition) { DRG::Ruby::Condition.new sexp }

  subject { described_class.new condition, ' ' * 10 }

  describe '#render' do
    context 'when the condition uses an enumerator with a block' do
      let(:file) { FIXTURE_ROOT.join('original_sexp_decorator.rb') }
      let(:parser) { RubyParser.new.parse File.read(file) }
      let(:const) { DRG::Ruby::Const.new(parser) }
      let(:condition) { const.funcs.first.conditions.last }

      it 'returns the first part of the enumerator' do
        expect(subject.render.join("\n")).to eq <<-RUBY.chomp
          context "when (exp.first == :if)" do
            before {}

            it "returns (yielded << exp)" do
            end

            context "when yielded.find do |x|" do
              before {}

              it "returns (yielded << sexp)" do
              end
            end

            context "not yielded.find do |x|" do
              before {}
            end
          end

          context "not (exp.first == :if)" do
            before {}
          end
        RUBY
      end
    end
  end

  describe '#escape' do
    context 'when the string has double quotes' do
      let(:txt) { 'File.exists?("file.rb")' }

      it 'escapes the double qoutes' do
        expect(subject.escape(txt)).to eq "\"File.exists?(\\\"file.rb\\\")\""
      end

      context 'when the string has interpolation' do
        let(:txt) { 'File.exists?("#{file}.rb") and name != \'foo\'' }

        it 'escapes interpolation' do
          expect(subject.escape(txt)).to eq "\"File.exists?(\\\"\\\#{file}.rb\\\") and name != 'foo'\""
        end

        it 'returns a valid string object' do
          expect(eval(subject.escape(txt))).to eq "File.exists?(\"\#{file}.rb\") and name != 'foo'"
        end

        context 'when interpolation is multiline' do
          let(:txt) { 'File.exists?("#{
file}.rb")' }

          it 'correctly escapes the interpolation' do
            expect(subject.escape(txt)).to eq "\"File.exists?(\\\"\\\#{\nfile}.rb\\\")\""
          end

          context 'when more complicated interpolation' do
            let(:txt) { 'File.exists?("#{file + \'name\'}.rb")' }

            it 'correctly escapes the interpolation' do
              expect(subject.escape(txt)).to eq "\"File.exists?(\\\"\\\#{file + 'name'}.rb\\\")\""
            end
          end

          context 'with multiple interpolations' do
            let(:txt) { 'File.exists?("#{file}.rb") and "#{name} #{age}" == "foo 25"' }

            it 'correctly escapes all interpolations' do
              expect(subject.escape(txt)).to eq "\"File.exists?(\\\"\\\#{file}.rb\\\") and \\\"\\\#{name} \\\#{age}\\\" == \\\"foo 25\\\"\""
            end
          end
        end
      end

      context 'when the string has backticks and interpolation' do
        let(:txt) { '`mv #{file_name} #{file_destination}`' }

        it 'correctly escapes all interpolations' do
          expect(subject.escape(txt)).to eq "\"`mv \\\#{file_name} \\\#{file_destination}`\""
        end

        it 'returns a valid string object' do
          expect(eval(subject.escape(txt))).to eq "`mv \#{file_name} \#{file_destination}`"
        end
      end

      context 'when the string is already escaped' do
        let(:txt) { Ruby2Ruby.new.process RubyParser.new.parse('errors << %Q(Couldn\'t find an option with name "#{name}")') }

        it 'returns a valid string object' do
          expect(eval(subject.escape(txt))).to eq "(errors << \"Couldn't find an option with name \"\#{name}\"\")"
        end
      end

    end
  end

end
