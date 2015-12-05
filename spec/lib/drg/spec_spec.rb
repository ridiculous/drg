require 'spec_helper'

describe DRG::Spec do
  let(:file) { FIXTURE_ROOT.join('report.rb') }

  subject { described_class.new file }

  describe '.perform' do
    it 'returns the spec for the given file as an array of lines' do
      expect(subject.perform.join("\n")).to eq %Q(require "spec_helper"

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
    it "assigns @message" do
    end
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

  describe "#go" do
    context "when (@duder == -1)" do
      before {}

      it "assigns @go = :ok" do
      end
    end

    context "not (@duder == -1)" do
      before {}
    end
  end

  describe "#call" do
    it "assigns @duder" do
    end

    context "unless (message[:verification_code_id] or message[\\"verification_code_id\\"])" do
      before {}

      it "returns []" do
      end
    end

    context "when (message[:verification_code_id] or message[\\"verification_code_id\\"])" do
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
    it "assigns @report" do
    end
  end

  describe "#verification_code" do
    it "assigns @verification_code" do
    end
  end

  describe ".find" do
  end

end
)
    end


    context 'given a file with a long if/elsif/else' do
      let(:file) { FIXTURE_ROOT.join('extensions.rb') }

      it 'returns an array of lines for the file' do
        expect(subject.perform.join("\n")).to eq %Q(require "spec_helper"

describe Extensions do
  subject { Class.new { include Extensions }.new }

  describe "#load_and_authorize_item!" do
    context "when coupon.nil?" do
      before {}

      it "returns fail(Error, \\"Couldn't find the coupon\\")" do
      end

      context "when coupon.expired?" do
        before {}

        it "returns fail(Error, \\"Coupon has expired\\")" do
        end
      end

      context "when coupon.inactive?" do
        before {}

        it "returns fail(Error, \\"Coupon is not activated\\")" do
        end
      end
      context "not coupon.inactive?" do
        before {}

        it "assigns @item = coupon" do
        end
      end
      context "when coupon.inactive?" do
        before {}

        it "returns fail(Error, \\"Coupon is not activated\\")" do
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

      it "returns fail(Error, \\"Coupon has been used up\\")" do
      end
    end
  end

  describe "#call" do
    it "assigns @called" do
    end
  end

  describe "#go" do
    it "assigns @go" do
    end
  end

  describe "#index" do
    it "assigns @title" do
    end
    it "assigns @finder" do
    end
    it "assigns @infections" do
    end
    it "assigns @notification" do
    end
  end

end
)
      end
    end

    context 'when given a file with a nested condition in a block' do
      let(:file) { FIXTURE_ROOT.join('controllers/application_controller.rb') }

      it 'rejects multiline statements to protect the client from our shortcomings' do
        expect(subject.perform.join("\n")).to eq %Q(require "spec_helper"

describe ApplicationController do

  subject { described_class.new  }

  describe ".before_filter" do
  end

  describe "#current_user" do
    it "assigns @current_user" do
    end

    context "when defined? @current_user" do
      before {}

      it "returns @current_user" do
      end

      context "when cookies[:auth_token]" do
        before {}

        it "returns User.find_by!(:auth_token => cookies[:auth_token])" do
        end
      end

      context "not cookies[:auth_token]" do
        before {}
      end
    end

    context "not defined? @current_user" do
      before {}
    end
  end

end
)
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
      expect(subject.funcs.length).to eq 12
      expect(subject.funcs.select(&:class?).length).to eq 4
      expect(subject.funcs.reject(&:class?).length).to eq 8
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

end
