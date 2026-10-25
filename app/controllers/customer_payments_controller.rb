class CustomerPaymentsController < ApplicationController
  def create
    @customer = Customer.find(params[:customer_id])

    payment = @customer.customer_payments.create!(
      payment_params.merge(received_at: Time.current)
    )

    # if @customer.email.present?
    #   begin
    #     CustomerMailer.customer_ledger(customer: @customer).deliver_now
    #   rescue StandardError => e
    #     Rails.logger.error(
    #       "Customer ledger email failed for customer #{@customer.id}: #{e.message}"
    #     )
    #   end
    # end

    if @customer.email.present?
      begin
        CustomerMailer.payment_received(
          customer: @customer,
          payment: payment
        ).deliver_now
      rescue StandardError => e
        Rails.logger.error(
          "Payment email failed for customer #{@customer.id}: " \
          "#{e.class} - #{e.message}"
        )
      end
    end

    if @customer.phone.present?
      total_bills = @customer.bills
        .where.not(finalized_at: nil)
        .sum(:total_amount)
    
      payments_before = @customer.customer_payments
        .where.not(id: payment.id)
        .sum(:amount)
    
      balance_before = total_bills - payments_before
      balance_after = balance_before - payment.amount
    
      message = <<~MSG
        BALAJI TRADERS 🙏
    
        Namaste #{@customer.name.to_s.titleize} ji!
    
        Payment se pehle udhaar: ₹#{format('%.2f', balance_before)}
        Abhi jama kiya: ₹#{format('%.2f', payment.amount)}
        Ab baaki udhaar: ₹#{format('%.2f', balance_after)}
    
        Dhanyavaad!
        BALAJI TRADERS, Lampuwa
      MSG
    
      @whatsapp_url = "https://wa.me/91#{@customer.phone}?text=#{ERB::Util.url_encode(message)}"
    end
    redirect_to @customer, notice: "Payment successfully received."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to customer_path(params[:customer_id]),
                alert: e.record.errors.full_messages.to_sentence
  end

  private

  def payment_params
    params.require(:customer_payment).permit(
      :amount, :payment_method, :notes
    )
  end
end
