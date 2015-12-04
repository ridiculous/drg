require "spec_helper"

describe DRG::Ruby::Assignment do
  let(:sexp) {}

  subject { described_class.new sexp }

  describe "#initialize" do
    it "assigns @sexp" do
    end
  end

  describe "#to_s" do
  end

  describe "#ivar_name" do
    context "when (sexp.first == :iasgn)" do
      before {}
      it "returns sexp[1]" do
      end
    end

    context "when (sexp.first == :op_asgn_or)" do
      before {}
      it "returns sexp[1][1]" do
      end
    end
  end

end
