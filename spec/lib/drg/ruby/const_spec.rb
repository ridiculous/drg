require 'spec_helper'

describe DRG::Ruby::Const do
  let(:parser) { RubyParser.new.parse File.read(file) }

  subject { described_class.new parser }

  describe '#name' do
    context 'when given a module' do
      let(:file) { FIXTURE_ROOT.join('extensions.rb') }

      it "returns the module's name" do
        expect(subject.name).to eq 'Extensions'
      end

      context "when the module is namespaced" do
        let(:file) { FIXTURE_ROOT.join('mixins/models.rb') }

        it "returns the module type" do
          expect(subject.name).to eq 'Mixins::Models'
        end
      end
    end

    context 'when given a class' do
      let(:file) { FIXTURE_ROOT.join('report.rb') }

      it 'returns the class names' do
        expect(subject.name).to eq 'Report'
      end

      context 'with inheritance' do
        let(:file) { FIXTURE_ROOT.join('controllers', 'reservations_controller.rb') }

        it 'returns the class names in the file' do
          expect(subject.name).to eq 'ReservationsController'
        end
      end

      context 'when the class is namespaced' do
        let(:file) { FIXTURE_ROOT.join('extensions', 'array.rb') }

        it 'returns the full modularized name' do
          expect(subject.name).to eq 'Extensions::Array'
        end
      end

      context 'when class is defined by creating a new Class' do
        let(:file) { FIXTURE_ROOT.join('adhoc_class.rb') }

        it 'returns the class name' do
          expect(subject.name).to eq 'Go'
        end
      end

      context 'when class is defined with namespace on same line' do
        let(:file) { FIXTURE_ROOT.join('controllers', 'admin', 'users_controller.rb') }

        it 'returns the class name' do
          expect(subject.name).to eq 'Admin::Super::UsersController'
        end
      end
    end
  end

  describe '#type' do
    context 'when given a module' do
      let(:file) { FIXTURE_ROOT.join('extensions.rb') }

      it "returns the module type" do
        expect(subject.type).to eq :module
      end

      context "when the module is namespaced" do
        let(:file) { FIXTURE_ROOT.join('mixins/models.rb') }

        it "returns the module type" do
          expect(subject.type).to eq :module
        end
      end
    end

    context 'when given a class' do
      let(:file) { FIXTURE_ROOT.join('report.rb') }

      it 'returns the class type' do
        expect(subject.type).to eq :class
      end

      context 'with inheritance' do
        let(:file) { FIXTURE_ROOT.join('controllers', 'reservations_controller.rb') }

        it 'returns the class types in the file' do
          expect(subject.type).to eq :class
        end
      end

      context 'when the class is namespaced' do
        let(:file) { FIXTURE_ROOT.join('extensions', 'array.rb') }

        it 'returns the full modularized type' do
          expect(subject.type).to eq :class
        end
      end

      context 'when class is defined by creating a new Class' do
        let(:file) { FIXTURE_ROOT.join('adhoc_class.rb') }

        it 'returns the class type' do
          expect(subject.type).to eq :class
        end
      end

      context 'when class is defined with namespace on same line' do
        let(:file) { FIXTURE_ROOT.join('controllers', 'admin', 'users_controller.rb') }

        it 'returns the class type' do
          expect(subject.type).to eq :class
        end
      end
    end
  end
end
