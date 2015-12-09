require 'spec_helper'

describe DRG::Tasks::Pinner do
  describe '#perform' do
    before do
      allow(subject).to receive(:log)
      allow(subject.gemfile).to receive(:write)
      allow(subject.gemfile).to receive(:find_by_name)
    end

    context 'when the gem is found' do
      let(:gem) { double(DRG::Tasks::GemfileLine) }

      it 'calls +update+ on the @gemfile with the -gem- and -version-' do
        expect(subject.gemfile).to receive(:find_by_name).with('rake').and_return(gem)
        expect(subject.gemfile).to receive(:update).with(gem, '10.4.2')
        subject.perform
      end
    end

    context 'when the gem is not found' do
      it 'does not call +update+ on the @gemfile' do
        expect(subject.gemfile).not_to receive(:update)
        subject.perform
      end
    end
  end

  describe '#full' do
    it 'returns the given -version-' do
      expect(subject.full('1.12.1.pre')).to eq '1.12.1.pre'
    end
  end

  describe '#patch' do
    it 'returns the fuzzy matched -version-' do
      expect(subject.patch('1.12.1')).to eq '~> 1.12.1'
    end
  end

  describe '#minor' do
    it 'returns the minor level of -version-' do
      expect(subject.minor('1.18.3')).to eq '~> 1.18'
      expect(subject.minor('1.9.10.2')).to eq '~> 1.9'
      expect(subject.minor('0.0.2')).to eq '0.0.2'
    end
  end

  describe '#major' do
    it 'returns the major level of -version-' do
      expect(subject.major('3.17.1')).to eq '~> 3'
      expect(subject.major('4.1.1.2')).to eq '~> 4'
      expect(subject.major('0.16.1.2')).to eq '~> 0.16'
      expect(subject.major('0.0.1.2')).to eq '0.0.1.2'
    end
  end
end
