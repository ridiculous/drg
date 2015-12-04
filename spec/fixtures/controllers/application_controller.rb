class ApplicationController
  def self.before_filter(*)
  end

  def current_user
    @current_user ||= defined?(@current_user) ? @current_user : begin
      User.find_by! auth_token: cookies[:auth_token] if cookies[:auth_token]
    rescue ActiveRecord::RecordNotFound
      Rails.logger.warn(%Q(Could not find user w/ token "#{cookies[:auth_token]}"))
      nil
    end
  end

  protected

  def authenticate!
    @authenticated = true
  end
end
