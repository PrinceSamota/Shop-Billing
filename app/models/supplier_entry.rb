class SupplierEntry < ApplicationRecord
  belongs_to :supplier

  ENTRY_TYPES = %w[purchase payment].freeze

  validates :entry_type, inclusion: { in: ENTRY_TYPES }
  validates :entry_date, presence: true
  validates :amount, numericality: { greater_than: 0 }

  scope :chronological, -> {
    order(:entry_date, :created_at, :id)
  }

  def particulars
    entry_type == "purchase" ? (note.presence || "Maal / Udhaar") : (note.presence || "Payment Jama")
  end
end