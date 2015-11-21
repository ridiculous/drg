require 'spec_helper'

describe DRG::Ruby::Klass do
  let(:sexp) { RubyParser.new.parse File.read(file) }
  let(:file) { FIXTURE_ROOT.join('report.rb') }

  subject { described_class.new sexp }

  describe '#name' do
    it 'returns the name of the class' do
      expect(subject.name).to eq 'Report'
    end
  end

  describe '#initialization_args' do
    it 'returns the args to initialize' do
      expect(subject.initialization_args).to eq [:message]
    end
  end

  describe '#func_by_name' do
    it 'returns the functions by name' do
      expect(subject.func_by_name(:verification_code)).to be_any
    end

    context 'whent the method is not found' do
      it 'returns nil' do
        expect(subject.func_by_name(:who_gives_a_func!)).to be nil
      end
    end
  end

  describe '#funcs' do
    it 'returns func objects' do
      expect(subject.funcs.first).to be_a(DRG::Ruby::ClassFunc)
      expect(subject.funcs.last).to be_a(DRG::Ruby::InstanceFunc)
    end

    it 'returns all the methods in the class' do
      expect(subject.funcs.map(&:name)).to eq [
                                                :enqueue, :process, :replace, :initialize, :map_args, :call, :report,
                                                :verification_code, :_secret_key_generator, :less_secret_stuff
                                              ]
    end

    it 'correctly marks the method public' do
      expect(subject.funcs.find { |f| f.name == :call }).to_not be_private
    end

    context 'when the function is private' do
      it 'correctly marks the method as private' do
        expect(subject.funcs.find { |f| f.name == :_secret_key_generator }).to be_private
      end
    end
  end
end
