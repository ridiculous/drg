require "spec_helper"

describe DRG::Tasks::SpecRunner do
  let(:file) {}

  subject { described_class.new file }

  describe "#initialize" do
  end

  describe "#perform" do
    context %Q[when (not File.exists?(file)) and (not File.exists?("@file.rb"))] do
      before {}
      it %Q[fail(ArgumentError, "File or directory does not exist: \"@file\"")] do
      end
    end

    context %Q[unless (not File.exists?(file)) and (not File.exists?("@file.rb"))] do
      before {}
    end
    context "unless spec" do
      before {}
    end

    context "when spec" do
      before {}
    end
  end

  describe "#ruby_files" do
    context "when File.directory?(file)" do
      before {}
      it %Q[(["@file.rb"])] do
      end
    end

    context "unless File.directory?(file)" do
      before {}
    end
  end

  describe "#spec_file" do
  end

  describe "#specify" do
  end

  describe "#spec_path" do
    context %Q[when File.directory?(File.expand_path("spec"))] do
      before {}
    end

    context %Q[unless File.directory?(File.expand_path("spec"))] do
      before {}
    end
  end

end
