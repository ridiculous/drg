class Report
  def self.enqueue(verification_code)
    return unless verification_code
    process(verification_code_id: verification_code.id)
  end

  def self.process(message)
    new(message).call
  end

  def self.replace(message, *args, &block)
    # do stuff
  end

  attr_reader :message

  def initialize(message = {})
    @message = message
  end

  def call
    return unless message[:verification_code_id]
    if report.save
      report.perform
    else
      report.failure
    end
  end

  def report
    @report ||= Report.new({
      status: 'queued',
      report_type: 'marketing_stuff',
      params: {
        verification_code_id: verification_code.id
      }
    })
  end

  def verification_code
    @verification_code ||= VerificationCode.find(message[:verification_id])
  end

  class VerificationCode
    def self.find(*)
    end
  end

  private

  def _secret_key_generator
    # super secret stuff here ...
  end

  def less_secret_stuff
    # super secret stuff here ...
  end
end
