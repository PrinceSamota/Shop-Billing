class CustomerPayment < ApplicationRecord
  belongs_to :customer
  validates :amount, presence: true,
  numericality: { greater_than: 0 }

  validates :received_at, presence: true

  before_validation :set_received_at, on: :create

  private

  def set_received_at
   self.received_at ||= Time.current
  end
end
