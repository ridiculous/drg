require 'spec_helper'

describe DRG::Tasks::GemfileLine do
  let(:line) { %Q(  gem "pry", '~> 0.10'\n) }
  let(:index) { 11 }

  subject { described_class.new(line, index) }

  describe '#update' do
    it 'updates the @line with the new version' do
      expect {
        subject.update('0.10.1')
      }.to change(subject, :line).from(%Q(  gem "pry", '~> 0.10'\n)).to(%Q(  gem "pry", '0.10.1'\n))
    end

    it 'updates the version to the given -version-' do
      expect {
        subject.update('0.10.1')
      }.to change(subject, :version).from("'~> 0.10'").to("'0.10.1'")
    end

    context "when the gem doesn't have a current version" do
      let(:line) { %Q(  gem 'byebug'\n) }

      it 'adds the new version' do
        expect {
          subject.update('4.2.1')
        }.to change(subject, :version).from(nil).to("'4.2.1'")
      end
    end

    context "when the gem is at the end of the file with no new line character" do
      let(:line) { %Q(  gem 'byebug') }

      it 'adds the new version' do
        expect {
          subject.update('4.2.1')
        }.to change(subject, :version).from(nil).to("'4.2.1'")
      end
    end

    context "when the gem has range set for it's version" do
      let(:line) { %Q(  gem 'byebug', '> 0.2.0', '< 1.0.0') }

      it 'adds the new version' do
        expect {
          subject.update('4.2.1')
        }.to change(subject, :version).from("'> 0.2.0', '< 1.0.0'").to("'4.2.1'")
      end
    end
  end

  describe '#version' do
    it 'returns the version of the gem' do
      expect(subject.version).to eq "'~> 0.10'"
    end
  end
end
