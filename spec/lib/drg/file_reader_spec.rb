# require 'spec_helper'
#
# describe DRG::FileReader do
#   let(:file) { FIXTURE_ROOT.join 'report.rb' }
#
#   subject { described_class.new(file) }
#
#   describe '#each' do
#     it 'returns at least the first line in @file' do
#       subject.each do |line|
#         expect(line).to eq "class Report\n"
#         break
#       end
#     end
#
#     context 'when no block is given' do
#       it 'returns an enumerator' do
#         expect(subject.each).to be_a Enumerable
#         expect(subject.each.to_a.count).to eq 58
#       end
#     end
#   end
# end
