require 'spec_helper'

describe DRG::Spec do
  let(:file) { FIXTURE_ROOT.join('report.rb') }

  subject { described_class.new file }

  describe '.generate' do
    it 'returns the spec for the given file as an array of lines' do
      expect(described_class.generate(file).join("\n")).to eq <<-RUBY
require "spec_helper"

describe Report do
  let(:message) {}

  subject { described_class.new message }

  describe ".enqueue" do
    context "unless verification_code" do
      before {}
      it "returns nil" do
      end
    end

    context "when verification_code" do
      before {}
    end
  end

  describe ".process" do
  end

  describe ".replace" do
  end

  describe "#initialize" do
  end

  describe "#map_args" do
    context "unless val" do
      before {}
      it "returns list" do
      end
    end

    context "when val" do
      before {}
    end
  end

  describe "#call" do
    context %Q[unless (message[:verification_code_id] or message["verification_code_id"])] do
      before {}
      it "returns []" do
      end
    end

    context %Q[when (message[:verification_code_id] or message["verification_code_id"])] do
      before {}
    end
    context "when (1 == 2)" do
      before {}
      it "returns 0" do
      end
    end

    context "not (1 == 2)" do
      before {}
      it "returns -1" do
      end
    end
    context "when report.save" do
      before {}
      it "returns report.perform" do
      end
      context "when user.wants_mail?" do
        before {}
        it "returns UserMailer.spam(user).deliver_now" do
        end
      end

      context "not user.wants_mail?" do
        before {}
      end
    end

    context "when report.save!" do
      before {}
      it "returns report.force_perform" do
      end
    end
    context "not report.save!" do
      before {}
      it "returns report.failure" do
      end
    end
  end

  describe "#report" do
  end

  describe "#verification_code" do
  end

  describe ".find" do
  end

end
      RUBY
    end


    context 'given a file with a long if/elsif/else' do
      let(:file) { FIXTURE_ROOT.join('extensions.rb') }

      it 'returns an array of lines for the file' do
        expect(described_class.generate(file).join("\n")).to eq <<-RUBY
require "spec_helper"

describe Extensions do
  subject { Class.new { include Extensions }.new }

  describe "#load_and_authorize_item!" do
    context "when coupon.nil?" do
      before {}
      it %Q[fail(Error, "Couldn't find the coupon")] do
      end
      context "when coupon.expired?" do
        before {}
        it %Q[fail(Error, "Coupon has expired")] do
        end
      end

      context "when coupon.inactive?" do
        before {}
        it %Q[fail(Error, "Coupon is not activated")] do
        end
      end
      context "not coupon.inactive?" do
        before {}
        it "assigns @item = coupon" do
        end
      end
      context "when coupon.inactive?" do
        before {}
        it %Q[fail(Error, "Coupon is not activated")] do
        end
      end

      context "not coupon.inactive?" do
        before {}
        it "assigns @item = coupon" do
        end
      end
    end

    context "when coupon.cannot_use?" do
      before {}
      it %Q[fail(Error, "Coupon has been used up")] do
      end
    end
  end

end
        RUBY
      end
    end
  end

  describe '#const' do
    it 'returns the Ruby constant defined in the given file' do
      expect(subject.const).to eq Report
    end
  end

  describe '#name' do
    it 'returns the name of the Ruby class in the given file' do
      expect(subject.name).to eq 'Report'
    end
  end

  describe '#funcs' do
    it 'returns an array with all the methods defined in the target file' do
      expect(subject.funcs).to be_a Array
      expect(subject.funcs.length).to eq 11
      expect(subject.funcs.select(&:class?).length).to eq 4
      expect(subject.funcs.reject(&:class?).length).to eq 7
      expect(subject.funcs.select(&:private?).length).to eq 2
      expect(subject.funcs.first.name).to eq :enqueue
      expect(subject.funcs.first.conditions.map(&:statement)).to eq ["return unless verification_code"]
    end
  end

  describe '#initialization_args' do
    it 'returns a list of args to initialize the class' do
      expect(subject.initialization_args).to eq [:message]
    end

    context 'when the subject takes multiple args' do
      let(:file) { FIXTURE_ROOT.join('multiple_args.rb') }

      it 'returns all the args' do
        expect(subject.initialization_args).to eq [:name, :age, :"*args"]
      end
    end

    context 'when the subject takes no args' do
      let(:file) { FIXTURE_ROOT.join('controllers/reservations_controller.rb') }

      it 'returns an empty array' do
        expect(subject.initialization_args).to eq []
      end
    end
  end

  describe '#class?' do
    context 'when the subject is a class' do
      it 'returns true' do
        expect(subject).to be_class
      end
    end

    context 'when the subject is a module' do
      let(:file) { FIXTURE_ROOT.join('mixins/models.rb') }

      it 'returns false' do
        expect(subject).to_not be_class
      end
    end
  end

  describe '#module?' do
    context 'when the subject is a module' do
      let(:file) { FIXTURE_ROOT.join('mixins/models.rb') }

      it 'returns true' do
        expect(subject).to be_module
      end
    end

    context 'when the subject is a class' do
      it 'returns false' do
        expect(subject).to_not be_module
      end
    end
  end

  describe '#quote' do
    context 'when the string has double quotes' do
      let(:txt) { 'File.exists?("file.rb")' }

      it 'escapes the double qoutes' do
        expect(subject.quote(txt)).to eq "%Q[File.exists?(\"file.rb\")]"
      end

      context 'when the string has interpolation' do
        let(:txt) { 'File.exists?("#{file}.rb") and name != \'foo\'' }

        it 'escapes interpolation' do
          expect(subject.quote(txt)).to eq "%Q[File.exists?(\"\\\#{file}.rb\") and name != 'foo']"
        end

        it 'returns a valid string object' do
          expect(eval(subject.quote(txt))).to eq "File.exists?(\"\#{file}.rb\") and name != 'foo'"
        end

        context 'when interpolation is multiline' do
          let(:txt) { 'File.exists?("#{
file}.rb")' }

          it 'correctly escapes the interpolation' do
            expect(subject.quote(txt)).to eq "%Q[File.exists?(\"\\\#{\nfile}.rb\")]"
          end

          context 'when more complicated interpolation' do
            let(:txt) { 'File.exists?("#{file + \'name\'}.rb")' }

            it 'correctly escapes the interpolation' do
              expect(subject.quote(txt)).to eq "%Q[File.exists?(\"\\\#{file + 'name'}.rb\")]"
            end
          end

          context 'with multiple interpolations' do
            let(:txt) { 'File.exists?("#{file}.rb") and "#{name} #{age}" == "foo 25"' }

            it 'correctly escapes all interpolations' do
              expect(subject.quote(txt)).to eq "%Q[File.exists?(\"\\\#{file}.rb\") and \"\\\#{name} \\\#{age}\" == \"foo 25\"]"
            end
          end
        end
      end
    end
  end

end
