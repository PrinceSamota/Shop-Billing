class SuppliersController < ApplicationController
  before_action :set_supplier, only: %i[show edit update]

  def index
    @suppliers = Supplier.order(:shop_name)
  end

  def new
    @supplier = Supplier.new
  end

  def create
    @supplier = Supplier.new(supplier_params)

    if @supplier.save
      redirect_to @supplier, notice: "Supplier successfully added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @entries = @supplier.supplier_entries
                        .order(entry_date: :desc, created_at: :desc, id: :desc)

    @total_udhaar = @supplier.total_udhaar
    @total_jama = @supplier.total_jama
    @current_balance = @supplier.current_balance

    @supplier_entry = @supplier.supplier_entries.new(
      entry_date: Date.current,
      entry_type: "purchase"
    )
  end

  def edit
  end

  def update
    if @supplier.update(supplier_params)
      redirect_to @supplier, notice: "Supplier details updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_supplier
    @supplier = Supplier.find(params[:id])
  end

  def supplier_params
    params.require(:supplier).permit(:shop_name, :dealer_name, :phone, :notes)
  end
end