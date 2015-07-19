require 'spec_helper'

describe DRG::Phile do

  let(:file) { FIXTURE_ROOT.join 'report.rb' }

  subject { described_class.new(file) }

  describe '#name' do
    it 'returns the name of the class under test' do
      expect(subject.name).to eq 'Report'
    end
  end

end
