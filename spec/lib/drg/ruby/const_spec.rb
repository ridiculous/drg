require 'spec_helper'

describe DRG::Ruby::Const do
  let(:file) { FIXTURE_ROOT.join('report.rb') }
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
                                                :enqueue, :process, :replace, :initialize, :map_args, :go, :call, :report,
                                                :verification_code, :find, :_secret_key_generator, :less_secret_stuff
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

    context 'parsing namespaced const' do
      let(:file) { FIXTURE_ROOT.join('mixins/helpers/date_helper.rb') }

      # @example of method sexp
      #   s(:defn, :initialize, s(:args, :date), s(:iasgn, :@date, s(:lvar, :date)))
      it 'returns the correct list of methods' do
        expect(subject.funcs.length).to eq 3
        expect(subject.funcs.reject(&:private?).length).to eq 2
        expect(subject.funcs.reject(&:private?).first.sexp[1]).to eq :initialize
        expect(subject.funcs.reject(&:private?).last.sexp[1]).to eq :perform
      end
    end

    context 'another file' do
      let(:file) { FIXTURE_ROOT.join('presenters', 'notification_presenter.rb')}

      it 'returns the methods in the file' do
        expect(subject.funcs).to be_kind_of Array
        expect(subject.funcs.length).to eq 4
        expect(subject.funcs.first).to be_kind_of DRG::Ruby::InstanceFunc
        expect(subject.funcs.first.sexp[1]).to eq :initialize
        expect(subject.funcs.first.conditions).to be_empty
        expect(subject.funcs.last.sexp[1]).to eq :new_handler
        expect(subject.funcs.last.conditions.length).to eq 1
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
