class LibraryStudent < ApplicationRecord
    has_many :library_payments, dependent: :restrict_with_error
  
    before_validation :set_default_status, on: :create
  
    validates :name, presence: true
    validates :admission_date, presence: true
    validates :monthly_fee, numericality: { greater_than: 0 }
    validates :status, inclusion: { in: %w[active left] }
  
    scope :active, -> { where(status: "active") }
    scope :left, -> { where(status: "left") }
  
    def active?
      status == "active"
    end
  
    def left?
      status == "left"
    end
  
    def total_paid
      library_payments.sum(:amount)
    end
  
    def days_remaining
      return nil unless fee_valid_till
  
      (fee_valid_till - Date.current).to_i
    end
  
    def fee_warning
      return nil unless active? && fee_valid_till
  
      days = days_remaining
  
      if days.negative?
        "Fee overdue"
      elsif days.zero?
        "Fee khatam aaj"
      elsif days <= 5
        "Fee #{days} din mein khatam"
      end
    end
  

    def recalculate_fee_valid_till!
      if admission_date.blank? || monthly_fee.to_d <= 0
        update_column(:fee_valid_till, nil)
        return
      end
    
      valid_till = admission_date - 1.day
      remaining_amount = 0.to_d
      monthly_fee_amount = monthly_fee.to_d
    
      library_payments.order(:payment_date, :id).each do |payment|
        next if payment.payment_date.blank?
        next if payment.amount.to_d <= 0
    
        remaining_amount += payment.amount.to_d
    
        while remaining_amount.positive?
          start_date = valid_till + 1.day
          next_month_date = start_date.next_month
          month_days = (next_month_date - start_date).to_i
    
          # Ek poore calendar month ki fee
          if remaining_amount >= monthly_fee_amount
            valid_till = next_month_date - 1.day
            remaining_amount -= monthly_fee_amount
          else
            # Partial fee ke liye current month ke actual days
            daily_fee = monthly_fee_amount / month_days
            covered_days = (remaining_amount / daily_fee).floor
    
            break if covered_days <= 0
    
            valid_till += covered_days.days
            remaining_amount -= daily_fee * covered_days
          end
        end
      end
    
      update_column(:fee_valid_till, valid_till)
    end
    
    private
  
    def set_default_status
      self.status = "active" if status.blank?
    end
  end
  