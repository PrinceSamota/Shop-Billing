class LibraryPayment < ApplicationRecord
  belongs_to :library_student

  validates :amount, numericality: { greater_than: 0 }
  validates :payment_date, presence: true
  validates :payment_method,
            inclusion: { in: %w[cash upi card other] },
            allow_blank: true

  after_commit :recalculate_student_fee, on: [:create, :update, :destroy]

  private

  def recalculate_student_fee
    student = LibraryStudent.find_by(id: library_student_id)
    student&.recalculate_fee_valid_till!
  end
end
