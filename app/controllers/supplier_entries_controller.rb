class SupplierEntriesController < ApplicationController
    before_action :set_supplier
  
    def create
      @supplier_entry = @supplier.supplier_entries.new(entry_params)
  
      if @supplier_entry.save
        redirect_to @supplier, notice: "Khata entry successfully saved."
      else
        redirect_to @supplier, alert: @supplier_entry.errors.full_messages.to_sentence
      end
    end
  
    private
  
    def set_supplier
      @supplier = Supplier.find(params[:supplier_id])
    end
  
    def entry_params
      params.require(:supplier_entry).permit(
        :entry_type, :entry_date, :amount, :note
      )
    end
  end