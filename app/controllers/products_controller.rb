class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy]

  def index
    @products = Product.order(created_at: :desc)

    if params[:search].present?
      search = "%#{Product.sanitize_sql_like(params[:search].strip.downcase)}%"

      @products = @products.where(
        "LOWER(name) LIKE :search OR sku ILIKE :search OR category ILIKE :search",
        search: search
      )
    end
  end


  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      redirect_to products_path, notice: "Product Successfully added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to products_path, notice: "Product successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path, notice: "Product deleted."
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :name, :sku, :purchase_price, :selling_price, :unit
    )
  end
end
