require 'spec_helper'
require 'drg/ruby'

describe DRG::Ruby do
  subject { described_class.new file }

  describe '#const_name' do
    context 'when given a module' do
      let(:file) { FIXTURE_ROOT.join('extensions.rb') }

      it "returns the module's name" do
        expect(subject.const_name).to eq 'Extensions'
      end
    end

    context 'when given a class' do
      let(:file) { FIXTURE_ROOT.join('report.rb') }

      it 'returns the class names' do
        expect(subject.const_name).to eq 'Report'
      end

      context 'with inheritance' do
        let(:file) { FIXTURE_ROOT.join('controllers', 'reservations_controller.rb') }

        it 'returns the class names in the file' do
          expect(subject.const_name).to eq 'ReservationsController'
        end
      end

      context 'when the class is namespaced' do
        let(:file) { FIXTURE_ROOT.join('extensions', 'array.rb') }

        it 'returns the full modularized name' do
          expect(subject.const_name).to eq 'Extensions::Array'
        end
      end

      context 'when class is defined by creating a new Class' do
        let(:file) { FIXTURE_ROOT.join('adhoc_class.rb') }

        it 'returns the class name' do
          expect(subject.const_name).to eq 'Go'
        end
      end

      context 'when class is defined with namespace on same line' do
        let(:file) { FIXTURE_ROOT.join('controllers', 'admin', 'users_controller.rb') }

        it 'returns the class name' do
          expect(subject.const_name).to eq 'Admin::Super::UsersController'
        end
      end
    end
  end
end
