class Product < ApplicationRecord
    before_validation :generate_sku, on: :create
    validates :name,
    presence: true,
    uniqueness: { case_sensitive: false }
    validates :sku, presence: true, uniqueness: true
    validates :purchase_price, :selling_price,
              numericality: { greater_than_or_equal_to: 0 }

private
def generate_sku
    return if sku.present?
  
    last_number = Product
      .where("sku ~ ?", "^SKU[0-9]+$")
      .pluck(:sku)
      .filter_map { |value| value.match(/\ASKU(\d+)\z/)&.captures&.first&.to_i }
      .max || 0
  
    self.sku = format("SKU%07d", last_number + 1)
  end
end
