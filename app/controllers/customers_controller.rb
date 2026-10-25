class CustomersController < ApplicationController
  before_action :set_customer, only: %i[show edit update destroy]
  def index
    @customers = Customer.order(created_at: :desc)

    if params[:search].present?
      term = "%#{Customer.sanitize_sql_like(params[:search].strip.downcase)}%"

      @customers = @customers.where(
        "LOWER(name) LIKE :term OR
         LOWER(phone) LIKE :term OR
         LOWER(customer_code) LIKE :term",
        term: term
      )
    end
  end

  def new
    @customer = Customer.new(active: true)
  end

  def create
    @customer = Customer.new(customer_params)

    if @customer.save
       redirect_to customers_path, notice: "Customer Successfully created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @bills = @customer.bills
                      .where.not(finalized_at: nil)
                      .includes(:bill_items)
                      .order(:finalized_at, :id)

    @customer_payments = @customer.customer_payments
                                  .order(:received_at, :id)

    @total_udhaar = @bills.sum { |bill| bill.total_amount.to_d }
    @bill_paid_total = @bills.sum { |bill| bill.paid_amount.to_d }
    @payments_total = @customer_payments.sum { |payment| payment.amount.to_d }

    @total_jama = @bill_paid_total + @payments_total
    @current_balance = @total_udhaar - @total_jama

    entries = []

    # Bill aur us bill par jama amount ek hi line mein
    @bills.each do |bill|
      entries << {
        date: bill.finalized_at || bill.created_at,
        priority: 0,
        particulars: "Bill #{bill.bill_number}",
        details: bill.bill_items.map do |item|
          "#{item.product_name} (#{item.quantity} #{item.unit})"
        end.join(", "),
        debit: bill.total_amount.to_d,
        credit: bill.paid_amount.to_d
      }
    end

    # Baad mein customer se li gayi payment alag line mein
    @customer_payments.each do |payment|
      entries << {
        date: payment.received_at || payment.created_at,
        priority: 1,
        particulars: "Cash Received",
        details: [payment.payment_method, payment.notes]
                  .compact_blank.join(" - "),
        debit: 0.to_d,
        credit: payment.amount.to_d,
        payment: payment
      }
    end

    # Running balance: purane se naye hisaab tak
    balance = 0.to_d

    @ledger_entries = entries
      .sort_by { |entry| [entry[:date], entry[:priority]] }
      .map do |entry|
        balance += entry[:debit].to_d - entry[:credit].to_d
        entry.merge(balance: balance)
      end
      .reverse
  end

  def edit
  end

  def update
    if @customer.update(customer_params)
      redirect_to customers_path, notice: "Customer Successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @customer.destroy
    redirect_to customers_path, notice: "Customer successfully deleted."
  end

  def bills
    @customer = Customer.find(params[:id])
  
    @bills = @customer.bills
                      .where.not(finalized_at: nil)
                      .includes(:bill_items)
                      .order(finalized_at: :desc, id: :desc)
  end


def export
  @customers = Customer.all

  if params[:search].present?
    term = "%#{params[:search].to_s.downcase}%"

    @customers = @customers.where(
      "LOWER(name) LIKE :term OR LOWER(phone) LIKE :term OR LOWER(customer_code) LIKE :term",
      term: term
    )
  end

  @customers = @customers.order(Arel.sql("LOWER(name) ASC"))

  @customer_balances = {}

  @customers.each do |customer|
    bills = customer.bills.where.not(finalized_at: nil)

    total_udhaar = bills.sum(:total_amount).to_d
    bill_jama = bills.sum(:paid_amount).to_d
    payment_jama = customer.customer_payments.sum(:amount).to_d

    @customer_balances[customer.id] =
      total_udhaar - bill_jama - payment_jama
  end

  respond_to do |format|
    format.csv do
      require "csv"

      csv_data = CSV.generate(headers: true) do |csv|
        csv << [
          "Customer Name",
          "Customer ID",
          "Customer Code",
          "Mobile Number",
          "Email",
          "Address",
          "Outstanding Balance"
        ]

        @customers.each do |customer|
          csv << [
            customer.name,
            customer.id,
            customer.customer_code,
            customer.phone,
            (customer.email if customer.respond_to?(:email)),
            customer.address,
            @customer_balances[customer.id].to_f
          ]
        end
      end

      send_data "\uFEFF#{csv_data}",
        filename: "customers-#{Date.current}.csv",
        type: "text/csv; charset=utf-8"
    end

    format.pdf do
      render pdf: "customers-#{Date.current}",
             template: "customers/export",
             layout: false
    end
  end
end


  private

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(
      :name,
      :phone,
      :address,
      :customer_code,
      :notes,
      :email,
      :active
    )
  end
end
