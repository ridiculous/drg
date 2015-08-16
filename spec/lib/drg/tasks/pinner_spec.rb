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
        expect(subject.gemfile).to receive(:find_by_name).with('pry').and_return(gem)
        expect(subject.gemfile).to receive(:update).with(gem, Gem::Version.new('0.10.1'))
        subject.perform
      end
    end

    context 'when the gem is not found' do
      it 'does not call +update+ on the @gemfile' do
        expect(subject.gemfile).not_to receive(:update)
        subject.perform
      end
    end

    it 'writes the contents of @lines back to the Gemfile' do
      expect(subject.gemfile).to receive(:write)
      subject.perform
    end
  end
end
