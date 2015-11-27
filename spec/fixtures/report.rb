class Report
  DEFAULT_TZ = 'UTC'

  def self.enqueue(verification_code)
    return unless verification_code
    process(verification_code_id: verification_code.id)
  end

  def self.process(message, opts = {}, duder = nil, whoa = { ok: 'yeah?' })
    new(message).call(opts)
  end

  def self.replace(message, *args, &block)
    # do stuff
  end

  attr_reader :message

  def initialize(message = {})
    @message = message
  end

  # @note ported from the source that's reading this :D
  def map_args(sexp, list = [])
    val = sexp.first
    return list unless val
    case val
      when Symbol
        map_args(sexp.drop(1), list << val)
      when Sexp
        map_args(sexp.drop(1), list << val[1])
      else
        nil
    end
  end

  def go
    if @duder == -1
      @go = :ok
    end
  end

  def call
    return [] unless message[:verification_code_id] or message["verification_code_id"]
    @duder = 1 == 2 ? 0 : -1
    if report.save
      if user.wants_mail?
        UserMailer.spam(user).deliver_now
      end
      report.perform
    elsif report.save!
      report.force_perform
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
