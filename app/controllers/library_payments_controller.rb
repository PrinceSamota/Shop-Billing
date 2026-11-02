class LibraryPaymentsController < ApplicationController
  before_action :set_library_student

  def new
    @library_payment = @library_student.library_payments.new(
      payment_date: Date.current,
      amount: @library_student.monthly_fee
    )
  end

  def create
    @library_payment = @library_student.library_payments.new(
      library_payment_params
    )

    if @library_payment.save
      redirect_to library_student_path(@library_student),
                  notice: "Fee payment successfully receive ho gayi."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_library_student
    @library_student = LibraryStudent.find(params[:library_student_id])
  end

  def library_payment_params
    params.require(:library_payment).permit(
      :amount,
      :payment_date,
      :payment_method,
      :notes
    )
  end
end