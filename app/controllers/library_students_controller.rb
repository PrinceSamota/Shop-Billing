
class LibraryStudentsController < ApplicationController
  before_action :set_library_student,
                only: [:show, :edit, :update, :mark_left, :mark_active]

  def index
    @students = LibraryStudent.all.order(:name)

    if params[:status].present?
      @students = @students.where(status: params[:status])
    end

    if params[:q].present?
      @students = @students.where(
        "name LIKE ? OR phone LIKE ?",
        "%#{params[:q]}%",
        "%#{params[:q]}%"
      )
    end

    @students = @students.to_a

    active_students = LibraryStudent.active
    @due_soon = active_students.where(
      fee_valid_till: Date.current..(Date.current + 5.days)
    ).order(:fee_valid_till)

    @due_today = active_students.where(fee_valid_till: Date.current)
    @overdue = active_students.where("fee_valid_till < ?", Date.current)
    @active_count = active_students.count
    @left_count = LibraryStudent.left.count
  end

  def show
    @payments = @library_student.library_payments.order(
      payment_date: :desc,
      id: :desc
    )
  end

  def new
    @library_student = LibraryStudent.new(
      admission_date: Date.current,
      monthly_fee: 1000,
      status: "active"
    )
  end

  def create
    @library_student = LibraryStudent.new(library_student_params)

    if @library_student.save
      redirect_to @library_student,
                  notice: "Student admission successfully add ho gaya."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @library_student.update(library_student_params)
      @library_student.recalculate_fee_valid_till!

      redirect_to @library_student,
                  notice: "Student details update ho gayi."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def mark_left
    if @library_student.update(status: "left", left_date: Date.current)
      redirect_to library_students_path,
                  notice: "Student ko Left mark kar diya."
    else
      redirect_to @library_student,
                  alert: @library_student.errors.full_messages.to_sentence
    end
  end

  def mark_active
    if @library_student.update(status: "active", left_date: nil)
      redirect_to @library_student,
                  notice: "Student ko Active kar diya."
    else
      redirect_to @library_student,
                  alert: @library_student.errors.full_messages.to_sentence
    end
  end

  private

  def set_library_student
    @library_student = LibraryStudent.find(params[:id])
  end

  def library_student_params
    params.require(:library_student).permit(
      :name,
      :phone,
      :admission_date,
      :monthly_fee,
      :status,
      :left_date,
      :notes
    )
  end
end
