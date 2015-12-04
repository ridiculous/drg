# require 'spec_helper'
#
# describe Report do
#   let(:verification_code) { create(:vcode) }
#   let(:report_double) { double('report') }
#   let(:long_let_var) do
#     this = double('name')
#     # is a multiline
#     this
#   end
#
#   context '.enqueue' do
#     context 'when verification_code is present' do
#       let(:worker) { double('worker').as_null_object }
#       let(:delay_time) { 30 }
#
#       it 'asynchronously publishes the message to the control center queue' do
#         expect(worker).to receive(:scheduled_publish).with(
#           'report',
#           { verification_code_id: verification_code.id },
#           delay_time
#         )
#         described_class.enqueue(verification_code, delay_time).join
#       end
#     end
#
#     context 'when verification_code is nil' do
#       it 'does nothing and returns nil' do
#         expect(described_class.enqueue(nil)).to be_nil
#       end
#     end
#   end
#
#   describe '.process' do
#     it 'parses the JSON param and calls #call on a new instance' do
#       expect(Report).to receive(:new).with({ verification_code_id: 666 }).and_return(report_double)
#       expect(report_double).to receive(:call)
#       Report.process('{"verification_code_id":666}')
#     end
#   end
#
#   context '#call' do
#     context 'when -message- has a :verification_code_id' do
#       let(:email_record) { subject.email_record }
#
#       subject { Report.new(verification_code_id: verification_code.id) }
#
#       context 'when the email saves successfully' do
#         before(:each) do
#           allow(email_record).to receive(:perform)
#         end
#
#         it 'creates an email record' do
#           expect { subject.call }.to change(Email, :count).by(1)
#         end
#
#         it 'calls +perform+ on the email record' do
#           expect(email_record).to receive(:perform)
#           subject.call
#         end
#
#         it 'changes the email status to "sent"' do
#           expect { subject.call }.to change(email_record, :status).from('queued').to('sent')
#         end
#       end
#
#       context 'when the email fails to save' do
#         it 'changes the email status to "failed"' do
#           expect(email_record).to receive(:save).and_return(false)
#           expect { subject.call }.to change(email_record, :status).from('queued').to('failed')
#         end
#       end
#     end
#
#     context 'when -message- :verification_code_id is nil' do
#       it 'does nothing and returns nil' do
#         expect_any_instance_of(Email).to_not receive(:save)
#         expect(subject.call).to be_nil
#       end
#     end
#   end
#
#   describe '.fake' do
#     context 'when inside an instance'
#   end
#
#   describe '#instance' do
#     context 'when inside an instance' do
#     end
#   end
# end
