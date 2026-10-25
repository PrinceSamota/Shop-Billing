class CustomerMailer < ApplicationMailer
    def test_email(to:)
      @message = "Dukaan Billing se Gmail SMTP test successful hai!"
  
      mail(
        to: to,
        from: ENV.fetch("GMAIL_USERNAME"),
        subject: "Dukaan Billing - Test Email"
      )
    end
  
    def customer_ledger(customer:)
      @customer = customer
      @bills = customer.bills
                        .where.not(finalized_at: nil)
                        .includes(:bill_items)
                        .order(:finalized_at, :id)
  
      @payments = customer.customer_payments.order(:received_at, :id)
  
      @total_udhaar = @bills.sum { |bill| bill.total_amount.to_d }
      @bill_paid_total = @bills.sum { |bill| bill.paid_amount.to_d }
      @payments_total = @payments.sum { |payment| payment.amount.to_d }
      @total_jama = @bill_paid_total + @payments_total
      @current_balance = @total_udhaar - @total_jama
  
      mail(
        to: @customer.email,
        from: ENV.fetch("GMAIL_USERNAME"),
        subject: "BALAJI TRADERS - Aapke Khate Ki Details"
      )
    end
  
    def bill_email(bill:)
      @bill = Bill.includes(:customer, :bill_items).find(bill.id)
  
      raise ArgumentError, "Bill abhi finalized nahi hua hai." if @bill.finalized_at.blank?
      raise ArgumentError, "Customer ka email address nahi hai." if @bill.customer&.email.blank?
  
      mail(
        to: @bill.customer.email,
        from: ENV.fetch("GMAIL_USERNAME"),
        subject: "BALAJI TRADERS - Bill #{@bill.bill_number}"
      )
    end
    def payment_received(customer:, payment:)
        @customer = customer
        @payment = payment
      
        @balance_before = customer.bills
          .where.not(finalized_at: nil)
          .where("finalized_at <= ?", payment.received_at)
          .sum(:total_amount)
      
        previous_payments = customer.customer_payments
          .where("received_at < ? OR (received_at = ? AND id < ?)",
                 payment.received_at, payment.received_at, payment.id)
          .sum(:amount)
      
        @balance_before -= previous_payments
        @balance_after = @balance_before - payment.amount
      
        mail(
          to: @customer.email,
          from: ENV.fetch("GMAIL_USERNAME"),
          subject: "BALAJI TRADERS - Payment Received"
        )
      end
  end
  