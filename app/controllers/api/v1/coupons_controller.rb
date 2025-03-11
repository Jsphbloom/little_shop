class Api::V1::CouponsController < ApplicationController
  rescue_from ActionController::ParameterMissing, with: :bad_request_response
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
  # rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity_response
  def index
    coupon_list = Coupon.all

    if params[:status].present? && params[:status] == "active"
      coupon_list = Coupon.active_true
    end

    if params[:status].present? && params[:status] == "inactive"
      coupon_list = Coupon.active_false
    end

    render json: CouponSerializer.new(coupon_list)
  end

  def show
    render json: CouponSerializer.new(Coupon.find(params[:id]))
  end

  def create
    coupon = Coupon.build(coupon_params)

    if coupon.nil?
      render json: { error: "No invoice found for this merchant" }, status: :unprocessable_entity
    elsif coupon.is_a?(Coupon) && coupon.save
      render json: CouponSerializer.new(coupon), status: :created
    else
      render json: { errors: coupon.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    coupon = Coupon.find(params[:id])
    coupon.update!(active: !coupon.active)
    render json: CouponSerializer.new(coupon)
  end

  private

  def coupon_params
    params.require(:coupon).permit(:name, :code, :discount_type, :discount_value, :merchant_id, :invoice_id, :active, :times_used)
  end

  def bad_request_response(e)
    render json: ErrorSerializer.format_error(e, "400"), status: :bad_request
  end

  def not_found_response(e)
    render json: ErrorSerializer.format_error(e, "404"), status: :not_found
  end

end
