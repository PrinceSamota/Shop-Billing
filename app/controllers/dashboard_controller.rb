
class DashboardController < ApplicationController
  def index
    today = Time.zone.now.beginning_of_day..Time.zone.now.end_of_day

    # Today's finalized bills
    today_bills = Bill.where(finalized_at: today)

    @today_sales = today_bills.sum(:total_amount)
    @today_bills_count = today_bills.count

    # Today's outstanding amount on today's bills
    @today_udhaar = today_bills.sum do |bill|
      [bill.total_amount.to_d - bill.paid_amount.to_d, 0.to_d].max
    end

    today_bill_received = today_bills.sum(:paid_amount).to_d

    # Money received today from customer payments
    today_customer_payments = CustomerPayment
      .where(received_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
      .sum(:amount)
      .to_d

    @today_money_received = today_bill_received + today_customer_payments

    # Today's estimated profit
    @today_profit = BillItem
      .joins(:bill, :product)
      .where(bills: { finalized_at: today })
      .sum(
        "bill_items.quantity * (bill_items.unit_price - products.purchase_price)"
      )

    # Overall customer outstanding balance
    finalized_bills = Bill.where.not(finalized_at: nil)

    total_udhaar = finalized_bills.sum(:total_amount).to_d
    bill_jama = finalized_bills.sum(:paid_amount).to_d
    payment_jama = CustomerPayment.sum(:amount).to_d

    @customer_udhaar = [
      total_udhaar - bill_jama - payment_jama,
      0.to_d
    ].max

    # Latest finalized bills
    @recent_bills = finalized_bills
      .includes(:customer)
      .order(finalized_at: :desc, id: :desc)
      .limit(5)
  end
end
