require 'spec_helper'

describe DRG::Tasks::Pinner do
  describe '#perform' do
    before do
      allow(subject).to receive(:log)
      allow(subject).to receive(:write_to_gemfile)
    end

    it 'updates the "pry" gem in @lines with the current version' do
      expect {
        subject.perform
      }.to change { subject.find_by_name('pry').to_s }.from(%Q(  gem "pry", '~> 0.10'\n)).to(%Q(  gem "pry", '0.10.1'\n))
    end

    it 'updates the "object_tracker" gem in @lines with the current version' do
      expect {
        subject.perform
      }.to change {
        subject.find_by_name('object_tracker').to_s
      }.from(%Q(  gem 'object_tracker', '>= 1.0.5'\n)).to(%Q(  gem 'object_tracker', '1.0.5'\n))
    end

    it 'updates the "byebug" gem in @lines with the current version' do
      expect {
        subject.perform
      }.to change {
        subject.find_by_name('byebug').to_s
      }.from(%Q(  gem 'byebug'\n)).to(%Q(  gem 'byebug', '5.0.0'\n))
    end

    it 'updates the "slop" gem in @lines with the current version' do
      expect {
        subject.perform
      }.to change {
        subject.find_by_name('slop').to_s
      }.from(%Q(gem 'slop')).to(%Q(gem 'slop', '3.6.0'\n))
    end

    it 'writes the contents of @lines back to the Gemfile' do
      expect(subject).to receive(:write_to_gemfile)
      subject.perform
    end
  end

  describe '#find_by_name' do
    it 'returns an object that responds to +version+' do
      expect(subject.find_by_name('pry')).to respond_to(:version)
    end

    it 'returns an object that responds to +index+' do
      expect(subject.find_by_name('pry')).to respond_to(:index)
    end

    context 'when the gem is listed with double quotes' do
      it 'returns the line with the gem' do
        expect(subject.find_by_name('pry')).to eq(%Q(  gem "pry", '~> 0.10'\n))
      end
    end

    context 'when the gem is listed with single quotes' do
      it 'returns the line with the gem' do
        expect(subject.find_by_name('object_tracker')).to eq("  gem 'object_tracker', '>= 1.0.5'\n")
      end
    end

    context 'when the gem cannot be found in the gemfile' do
      it 'returns nil' do
        expect(subject.find_by_name('foo')).to eq(nil)
      end
    end

    context 'when the gem is found but has the :path option set' do
      it 'returns nil' do
        expect(subject).to receive(:lines).and_return([%Q(gem 'rails', path: '../gems/rails')])
        expect(subject).to receive(:lines).and_return([%Q(gem 'pg', :path => '../gems/rails')])
        expect(subject.find_by_name('rails')).to be_nil
        expect(subject.find_by_name('pg')).to be_nil
      end
    end

    context 'when the gem is found but has the :git option set' do
      it 'returns nil' do
        expect(subject).to receive(:lines).and_return([%Q(gem 'rails', git: '...')])
        expect(subject).to receive(:lines).and_return([%Q(gem 'pg', :git => '...')])
        expect(subject.find_by_name('rails')).to be_nil
        expect(subject.find_by_name('pg')).to be_nil
      end
    end

    context 'when the gem is found but has the :github option set' do
      it 'returns nil' do
        expect(subject).to receive(:lines).and_return([%Q(gem 'rails', github: '...')])
        expect(subject).to receive(:lines).and_return([%Q(gem 'pg', :github => '...')])
        expect(subject.find_by_name('rails')).to be_nil
        expect(subject.find_by_name('pg')).to be_nil
      end
    end
  end

  describe '#lines' do
    it 'returns the lines of the gemfile' do
      expect(subject.lines).to include(/  gem 'object_tracker'/)
    end
  end
end
