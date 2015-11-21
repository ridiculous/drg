require_relative 'application_controller'

class ReservationsController < ApplicationController
  before_filter :config_nav

  def new
    @reservation = Reservation.new
  end

  def create
    @reservation = Reservation.new(reservation_params)
    if @reservation.save
      ReservationMailer.reservation(@reservation).deliver_later
      redirect_to charter_path, notice: "Thank you for contacting us. We'll get back to you at our earliest convenience."
    elsif params[:duder].nil? && "whodat" != params[:name]
      # some other crud
    else
      request.flash[:errors] = @reservation.errors.full_messages
      render :new
    end
  end

  private

  def reservation_params
    params.require(:reservation).permit!
  end

  def config_nav
    @current_page = :charter
    @page_title = 'Contact'
  end

end
