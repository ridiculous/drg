require 'spec_helper'

describe DRG::Judge do
  let(:file) { FIXTURE_ROOT.join 'report.rb' }
  let(:spec) { FIXTURE_ROOT.join 'report_spec.rb' }

  subject { described_class.new file, spec }

  describe '.missing_methods' do
    it 'returns the methods that do not exist in the spec' do
      expect(subject.missing_methods).to eq %w[
        Report.replace Report#initialize Report#report Report#verification_code Report::VerificationCode.find
      ]
    end

    it 'excludes private methods' do
      expect(subject.missing_methods).to_not include('_secret_key_generator', 'less_secret_stuff')
    end
  end
end
