require 'spec_helper'

describe DRG::Scanner do
  let(:file) { FIXTURE_ROOT.join 'report_spec.rb' }

  subject { described_class.new file }

  describe '#indentation' do
    it 'returns what appears to be the the indentation size for the file' do
      expect(subject.indentation).to eq 2
    end
  end

  describe '#methods' do
    context 'when the file has method definitions' do
      let(:file) { FIXTURE_ROOT.join 'report.rb' }

      it 'excludes private methods' do
        expect(subject.methods).to_not include('_secret_key_generator', 'less_secret_stuff')
      end

      it 'returns all the methods in a file' do
        expect(subject.methods).to eq %w[
        Report.enqueue Report.process Report.replace Report#initialize Report#call
        Report#report Report#verification_code Report::VerificationCode.find
      ]
      end
    end

    context 'when the file has no method definitions' do
      it 'returns an empty array' do
        expect(subject.methods).to eq []
      end
    end
  end

  describe '#describes' do
    it 'returns all the describes and contexts in the spec' do
      expect(subject.describes).to eq [
        ".enqueue", "when verification_code is present", "when verification_code is nil",
        ".process", "#call", "when -message- has a :verification_code_id", "when the email saves successfully",
        "when the email fails to save", "when -message- :verification_code_id is nil", ".fake", "when inside an instance",
        "#instance", "when inside an instance"
      ]
    end
  end

  describe '#lets' do
    it 'returns all the +let+ calls in the given file' do
      expect(subject.lets.length).to eq 6
      expect(subject.lets.all? { |let| let.name =~ /\Alet/ })
    end

    it 'returns the name and value for the first let' do
      expect(subject.lets.first.name).to eq 'verification_code'
      expect(subject.lets.first.value).to eq 'create(:vcode)'
    end

    it 'returns the lets that have multiline definitions' do
      let = subject.lets.detect { |x| x.name == 'long_let_var' }
      expect(let.name).to eq 'long_let_var'
      expect(let.value).to eq "    this = double('name')\n    # is a multiline\n    this\n"
    end
  end

end
