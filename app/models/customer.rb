class Customer < ApplicationRecord
before_validation :generate_customer_code, on: :create
has_many :bills, dependent: :nullify
has_many :customer_payments, dependent: :destroy
validates :name, presence: true
validates :phone, presence: true,
                  format: {
                    with: /\A[0-9]{10}\z/,
                    message: "must be a valid 10-digit mobile number"
                  }
validates :phone, uniqueness: {
    message: "Is already registered"
}
validates :customer_code, presence: true, uniqueness: true
private
    def generate_customer_code
        return if customer_code.present?

        last_number = Customer.maximum(:id).to_i + 1
        self.customer_code = format("CUS%09d", last_number)
    end
end
