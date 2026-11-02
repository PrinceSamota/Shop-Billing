class Supplier < ApplicationRecord
    has_many :supplier_entries, dependent: :destroy
  
    validates :shop_name, presence: true
  
    def total_udhaar
      supplier_entries
        .where(entry_type: "purchase")
        .sum(:amount)
    end
  
    def total_jama
      supplier_entries
        .where(entry_type: "payment")
        .sum(:amount)
    end
  
    def current_balance
      total_udhaar - total_jama
    end
  end