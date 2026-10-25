class Bill < ApplicationRecord
  belongs_to :customer, optional: true
  has_many :bill_items, dependent: :destroy

  before_validation :generate_bill_number, on: :create

  validates :bill_number, presence: true, uniqueness: true

  private

  def generate_bill_number
    return if bill_number.present?

    last_number = Bill.where("bill_number LIKE ?", "BILL%")
                      .pluck(:bill_number)
                      .filter_map { |number| number.match(/\ABILL(\d+)\z/)&.captures&.first&.to_i }
                      .max || 0

    self.bill_number = format("BILL%06d", last_number + 1)
  end
end
