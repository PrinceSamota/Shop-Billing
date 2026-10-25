class BillsController < ApplicationController
  def index
    @bills = Bill.includes(:customer).order(created_at: :desc)
  end

  def create
    bill_params = params.require(:bill)
    action_type = bill_params[:submission_action].to_s

    unless %w[draft finalized].include?(action_type)
      return redirect_to new_bill_path, alert: "Invalid bill action."
    end

    items = JSON.parse(bill_params[:items_json].presence || "[]")

    if action_type == "finalized" && items.empty?
      return redirect_to new_bill_path, alert: "Complete bill ke liye kam se kam ek item add karo."
    end

    customer_id = bill_params[:customer_id].presence
    customer = Customer.find_by(id: customer_id) if customer_id

    if customer_id && customer.nil?
      return redirect_to new_bill_path, alert: "Selected customer nahi mila."
    end

    # Customer ka purana udhaar calculate karo
    old_balance = 0.to_d

    if customer
      previous_bills = customer.bills.where.not(finalized_at: nil)

      old_balance = [
        previous_bills.sum(:total_amount).to_d -
          previous_bills.sum(:paid_amount).to_d -
          customer.customer_payments.sum(:amount).to_d,
        0.to_d
      ].max
    end

    old_udhaar_payment = BigDecimal(
      bill_params[:old_udhaar_payment].presence || "0"
    )

    if old_udhaar_payment.negative?
      raise ArgumentError, "Old udhaar payment negative nahi ho sakti."
    end

    if old_udhaar_payment.positive? && customer.nil?
      raise ArgumentError, "Old udhaar payment ke liye customer select karo."
    end

    if old_udhaar_payment > old_balance
      raise ArgumentError, "Old udhaar payment purane balance se zyada hai."
    end

    prepared_items = items.map do |item|
      product_id = item["product_id"].presence
      product = Product.find_by(id: product_id) if product_id

      raise ActiveRecord::RecordNotFound, "Selected product nahi mila." if product_id && product.nil?

      quantity = BigDecimal(item["quantity"].to_s)
      unit_price = BigDecimal(item["unit_price"].to_s)

      raise ArgumentError, "Quantity zero se zyada honi chahiye." unless quantity.positive?
      raise ArgumentError, "Rate negative nahi ho sakta." if unit_price.negative?

      {
        product: product,
        product_name: product ? product.name : item["name"].to_s.strip,
        sku: product ? product.sku : item["sku"].to_s,
        unit: product ? product.unit.presence || "pcs" : item["unit"].presence || "pcs",
        quantity: quantity,
        unit_price: unit_price,
        line_total: (quantity * unit_price).round(2)
      }
    end

    if prepared_items.any? { |item| item[:product_name].blank? }
      return redirect_to new_bill_path, alert: "Har item ka naam hona chahiye."
    end

    subtotal = prepared_items.sum { |item| item[:line_total] }.round(2)
    requested_discount = BigDecimal(bill_params[:discount_amount].presence || "0")
    raise ArgumentError, "Discount negative nahi ho sakta." if requested_discount.negative?

    discount = [requested_discount, subtotal].min.round(2)
    total = (subtotal - discount).round(2)

    payment_mode = bill_params[:payment_mode].to_s

    paid = case payment_mode
           when "full"
             total
           when "credit"
             0.to_d
           when "partial"
             BigDecimal(bill_params[:paid_amount].presence || "0")
           else
             raise ArgumentError, "Invalid payment type."
           end

    raise ArgumentError, "Paid amount negative nahi ho sakta." if paid.negative?
    raise ArgumentError, "Paid amount bill total se zyada nahi ho sakta." if paid > total

    payment_status =
      if paid.zero?
        "unpaid"
      elsif paid >= total
        "paid"
      else
        "partial"
      end

    # Draft mein payment record nahi banega
    if action_type == "draft" && old_udhaar_payment.positive?
      raise ArgumentError, "Draft bill mein old udhaar payment save nahi ho sakti."
    end

    @bill = nil

    Bill.transaction do
      @bill = Bill.create!(
        customer: customer,
        walk_in_name: customer.nil? ? bill_params[:walk_in_name].to_s.strip.presence : nil,
        status: action_type == "draft" ? "draft" : "finalized",
        subtotal: subtotal,
        discount_amount: discount,
        tax_amount: 0,
        total_amount: total,
        paid_amount: paid,
        payment_status: payment_status,
        finalized_at: action_type == "finalized" ? Time.current : nil
      )

      prepared_items.each do |item|
        @bill.bill_items.create!(
          product: item[:product],
          product_name: item[:product_name],
          sku: item[:sku],
          unit: item[:unit],
          quantity: item[:quantity],
          unit_price: item[:unit_price],
          line_total: item[:line_total]
        )
      end

      # Purane udhaar mein jama amount alag CustomerPayment ke roop mein save hoga
      if action_type == "finalized" &&
         customer.present? &&
         old_udhaar_payment.positive?

        customer.customer_payments.create!(
          amount: old_udhaar_payment,
          payment_method: bill_params[:payment_method].presence || "cash",
          notes: "Previous udhaar payment for bill #{@bill.bill_number}",
          received_at: Time.current
        )
      end
    end

    if customer.nil?
      flash[:walk_in_name] = bill_params[:walk_in_name].to_s.strip
      flash[:walk_in_phone] = bill_params[:walk_in_phone].to_s.strip
    end
    
    redirect_to bill_path(@bill),
                notice: action_type == "draft" ? "Bill draft mein save ho gaya." : "Bill successfully complete ho gaya."
  rescue JSON::ParserError, ArgumentError, ActiveRecord::RecordNotFound,
         ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid => e
    redirect_to new_bill_path, alert: "Bill save nahi hua: #{e.message}"
  end

  def new
    @bill = Bill.new
    @bill.bill_items.build
    @customers = Customer.order(:name)
    @products = Product.order(:name)
    @customer_balances = {}

    @customers.each do |customer|
      bills = customer.bills.where.not(finalized_at: nil)

      total_bills = bills.sum(:total_amount).to_d
      bill_payments = bills.sum(:paid_amount).to_d
      other_payments = customer.customer_payments.sum(:amount).to_d

      balance = total_bills - bill_payments - other_payments

      @customer_balances[customer.id] = [balance, 0.to_d].max
    end
  end


  def show
    @bill = Bill.includes(:customer, :bill_items).find(params[:id])
  
    @previous_udhaar = 0.to_d
    @old_udhaar_payment = 0.to_d
  
    if @bill.customer.present?
      customer = @bill.customer
  
      # Is bill se pehle ka udhaar
      previous_bills = customer.bills
        .where.not(finalized_at: nil)
        .where("created_at < ?", @bill.created_at)
  
      previous_bill_total = previous_bills.sum(:total_amount).to_d
      previous_bill_paid = previous_bills.sum(:paid_amount).to_d
  
      previous_payments = customer.customer_payments
        .where("received_at < ?", @bill.created_at)
        .sum(:amount).to_d
  
      @previous_udhaar = [
        previous_bill_total - previous_bill_paid - previous_payments,
        0.to_d
      ].max
  
      # Is bill ke liye save hui purane udhaar ki payment
      if @bill.bill_number.present?
        @old_udhaar_payment = customer.customer_payments
          .where("notes LIKE ?", "%Previous udhaar payment for bill #{@bill.bill_number}%")
          .sum(:amount).to_d
      end
    end
  end
  
  def send_bill_email
    @bill = Bill.includes(:customer, :bill_items).find(params[:id])
  
    unless @bill.finalized_at.present?
      return redirect_to bill_path(@bill),
                         alert: "Draft bill ka email nahi bhej sakte."
    end
  
    if @bill.customer&.email.blank?
      return redirect_to bill_path(@bill),
                         alert: "Customer ka email address add karo."
    end
  
    CustomerMailer.bill_email(bill: @bill).deliver_now
  
    redirect_to bill_path(@bill),
                notice: "Poora bill customer ke email par bhej diya gaya."
  rescue StandardError => e
    Rails.logger.error(
      "Bill email failed for bill #{params[:id]}: #{e.class} - #{e.message}"
    )
  
    redirect_to bill_path(params[:id]),
                alert: "Email send nahi hua. Customer email aur SMTP settings check karo."
  end

end