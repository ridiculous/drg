require 'spec_helper'

describe DRG::Tasks::Gemfile do
  subject { described_class.new FIXTURE_ROOT.join('Gemfile') }

  let(:gem) { subject.find_by_name('pry') }

  describe '#initialize' do
    context 'when no Gemfile is specified' do
      subject { described_class.new }

      it "defaults to Bundler's Gemfile" do
        expect(subject.file).to eq Bundler.default_gemfile
      end
    end
  end

  describe '#remove_version' do
    before { allow(subject).to receive(:write) }

    it 'assigns the current value of @lines to @saved_lines' do
      original_lines = Marshal.load(Marshal.dump(subject.lines))
      expect { subject.remove_version(gem) }.to change { subject.saved_lines }.from([]).to([original_lines])
    end

    it 'removes the version for the gem' do
      gem = subject.find_by_name('rack-cache')
      expect { subject.remove_version(gem) }.to change(gem, :to_s).to(%Q(  gem 'rack-cache', :require => 'rack/cache'\n))
    end

    context "whent the gem doesn't have a gem version set" do
      it 'does nothing' do
        gem = subject.find_by_name('usable')
        expect { subject.remove_version(gem) }.to_not change(gem, :to_s)
      end
    end

  end

  describe '#update' do
    it 'assigns the current value of @lines to @saved_lines' do
      original_lines = Marshal.load(Marshal.dump(subject.lines))
      expect { subject.update(gem, '0.10.1') }.to change { subject.saved_lines }.from([]).to([original_lines])
    end

    it 'updates the gem index in @lines to the given -version-' do
      expect { subject.update(gem, '~> 1.10.1') }.to change { subject.lines[gem] }.to(%Q(  gem "pry", '~> 1.10.1'\n))
    end

    it 'updates the "pry" gem to the given -version-' do
      expect {
        subject.update(gem, '0.10.1')
      }.to change(gem, :to_s).from(%Q(  gem "pry", '~> 0.10'\n)).to(%Q(  gem "pry", '0.10.1'\n))
    end

    it 'updates the "object_tracker" gem to the given -version-' do
      gem = subject.find_by_name('object_tracker')
      expect {
        subject.update(gem, '1.0.5')
      }.to change(gem, :to_s).from(%Q(  gem 'object_tracker', '>= 1.0.5'\n)).to(%Q(  gem 'object_tracker', '1.0.5'\n))
    end

    it 'updates the "byebug" gem to the given -version-' do
      gem = subject.find_by_name('byebug')
      expect {
        subject.update(gem, '5.0.0')
      }.to change(gem, :to_s).to(%Q(  gem 'byebug', '5.0.0', :require => false\n))
    end

    it 'updates the "rack-cache" gem to the given -version-' do
      gem = subject.find_by_name('rack-cache')
      expect {
        subject.update(gem, '1.5.1')
      }.to change(gem, :to_s).to(%Q(  gem 'rack-cache', '1.5.1', :require => 'rack/cache'\n))
    end

    it 'updates the "slop" gem to the given -version-' do
      gem = subject.find_by_name('slop')
      expect {
        subject.update(gem, '3.6.0')
      }.to change(gem, :to_s).from(%Q(gem 'slop'\n)).to(%Q(gem 'slop', '3.6.0'\n))
    end

    it 'updates the "aws-sdk" gem to the given -version- and preserves spacing' do
      gem = subject.find_by_name('aws-sdk')
      expect {
        subject.update(gem, '2.2.1')
      }.to change(gem, :to_s).to(%Q(gem 'aws-sdk',                  '2.2.1'   # Amazon Web Services\n))
    end

    it 'updates the "whenever" gem with the given -version-' do
      gem = subject.find_by_name('whenever')
      expect {
        subject.update(gem, '~> 2.6')
      }.to change(gem, :to_s).to(%Q(gem "whenever", '~> 2.6',                 require: false\n))
    end

    it 'updates the "git" gem with the given -version-' do
      gem = subject.find_by_name('git')
      expect {
        subject.update(gem, '~> 1.3')
      }.to change(gem, :to_s).to(%Q(gem 'git',          '~> 1.3',   # Git that repo\n))
    end

    it 'updates the "duck_puncher" gem with the given -version-' do
      gem = subject.find_by_name('duck_puncher')
      expect {
        subject.update(gem, '~> 4.4')
      }.to change(gem, :to_s).to(%Q(gem 'duck_puncher', '~> 4.4'        # Precision monkey patches\n))
    end
  end

  describe '#find_by_name' do
    it 'returns an object that responds to +version+' do
      expect(gem).to respond_to(:version)
    end

    it 'returns an object that responds to +index+' do
      expect(gem).to respond_to(:index)
    end

    context 'when the gem is listed with double quotes' do
      it 'returns the line with the gem' do
        expect(gem).to eq(%Q(  gem "pry", '~> 0.10'\n))
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

    context 'when the requested gem is commented out' do
      it 'returns nil' do
        expect(subject.find_by_name('rubocop')).to be_nil
        expect(subject.find_by_name('foo')).to be_nil
      end
    end

    context 'when the line has a @drg comment specifying to skip the gem' do
      it 'returns nil' do
        expect(subject).to receive(:lines).and_return ["gem 'slop'", "  gem 'byebug', require: false\n"]
        expect(subject.find_by_name('slop')).to be_a DRG::Tasks::GemfileLine
        expect(subject).to receive(:lines).and_return ["gem 'slop'  # @drg  skip", "  gem 'byebug', require: false\n"]
        expect(subject.find_by_name('slop')).to be_nil
      end
    end
  end

  describe '#lines' do
    it 'returns the lines of the gemfile' do
      expect(subject.lines).to include(/  gem 'object_tracker'/)
    end
  end
end
