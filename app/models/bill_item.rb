class BillItem < ApplicationRecord
  belongs_to :bill
  belongs_to :product, optional: true
  validates :product_name, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }
end
