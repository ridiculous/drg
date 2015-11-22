require "spec_helper"

describe DRG::Decorators::SexpDecorator do

  subject { described_class.new  }

  describe "#each_sexp_condition" do
    context "unless block_given?" do
      before {}
      it "returns enum_for(__method__)" do
      end
    end

    context "when block_given?" do
      before {}
    end
    context "unless exp.is_a?(Sexp)" do
      before {}
      it "returns next" do
      end
    end

    context "when exp.is_a?(Sexp)" do
      before {}
    end
  end

end
