require 'spec_helper'

describe DRG::Tasks::ActivePinner do
  let(:versions) { ['1.0.0', '0.19.1', '0.19.0', '0.18.10', '0.18.3', '0.18.2', '0.18.1', '0.18.0', '0.9.0', '0.8.0', '0.7.9.2008.10.13', '0.7.9.2008.03.18', '0.7.9.2008.02.05', '32'] }

  describe '#latest_patch_version' do
    before { subject.versions = { 'pg' => versions } }

    context 'when there are new patches available' do
      it 'returns the latest patch version available' do
        expect(subject.latest_patch_version('pg', Gem::Version.new('0.18.0'))).to eq '0.18.10'
      end
    end

    context 'when using the latest patch' do
      it 'returns nil' do
        expect(subject.latest_patch_version('pg', Gem::Version.new('0.19.1'))).to eq nil
      end
    end
  end

  describe '#latest_minor_version' do
    before { subject.versions = { 'pg' => versions } }
    context 'when there are new minor versions are available' do
      it 'returns the latest minor version available' do
        expect(subject.latest_minor_version('pg', Gem::Version.new('0.18.0'))).to eq '0.19.1'
        expect(subject.latest_minor_version('pg', Gem::Version.new('0.7.9.2008.10.13'))).to eq '0.19.1'
        expect(subject.latest_minor_version('pg', Gem::Version.new('0.19.1'))).to be_nil
      end
    end
  end

  describe '#higher?' do
    before { subject.versions = { 'pg' => versions } }
    context 'when -list- has a higher semantic version that -other_list-' do
      it 'returns true' do
        expect(subject.higher?([0, 29, 11], [0, 29, 1])).to be true
        expect(subject.higher?([1, 0, 0], [0, 29, 1])).to be true
        expect(subject.higher?([2, 1, 23], [2, 1, 22])).to be true
        expect(subject.higher?([0, 8, 0], [0, 7, 9, 2008, 10, 13])).to be true
      end
    end

    context 'when -list- does not have a higher semantic version that -other_list-' do
      it 'returns true' do
        expect(subject.higher?([1, 0, 0], [1, 0, 0])).to be false
        expect(subject.higher?([1, 0, 0], [2, 0, 0])).to be false
        expect(subject.higher?([1, 2, 33], [1, 2, 34])).to be false
        expect(subject.higher?([0, 2, 0], [0, 2, 1])).to be false
        expect(subject.higher?([0, 2, 1], [0, 2, 11])).to be false
      end
    end
  end

  describe '#load_versions' do
    let(:gem_versions) { "rails_on_heroku (0.0.2)\nrails_on_pg (0.0.1)\nrails (3.2.23, 3.2.0, 3.1.2)\npg (0.2.2, 0.2.1, 0.0.12)\ngrails\nrspec-rails (3.3.3)" }

    before { allow(subject).to receive(:load_gem_versions).and_return(gem_versions) }

    context 'when one gem is given' do
      it "adds the gem and it's versions to @versions" do
        expect {
          subject.load_versions('rails')
        }.to change { subject.instance_variable_get(:@versions) }.from({}).to({ 'rails' => ['3.2.23', '3.2.0', '3.1.2'] })
      end

      it "handles underscores just fine" do
        expect {
          subject.load_versions('rails_on_heroku')
        }.to change { subject.instance_variable_get(:@versions) }.from({}).to({ 'rails_on_heroku' => ['0.0.2'] })
      end
    end

    context 'when an array of gems are given' do
      it "adds the gems and it's versions to @versions" do
        expect {
          subject.load_versions(%w[rails pg rspec-rails])
        }.to change {
          subject.instance_variable_get(:@versions)
        }.from({}).to({ 'pg' => ['0.2.2', '0.2.1', '0.0.12'], 'rails' => ['3.2.23', '3.2.0', '3.1.2'], "rspec-rails" => ["3.3.3"] })
      end
    end
  end
end
