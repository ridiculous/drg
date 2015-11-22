require "spec_helper"

describe DRG::Tasks::Updater do

  subject { described_class.new  }

  describe "#initialize" do
  end

  describe "#perform" do
    context "when gemfile.find_by_name(name)" do
      before {}
      it "returns name" do
      end
    end

    context "unless gemfile.find_by_name(name)" do
      before {}
    end
    context "when gems.any?" do
      before {}
      it "(yield(gems))" do
      end
    end

    context "not gems.any?" do
      before {}
    end
  end

end
