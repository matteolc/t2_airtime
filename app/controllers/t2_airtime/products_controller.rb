module T2Airtime
  # Proxy products information
  class ProductsController < ApplicationController
    def index
      @products = T2Airtime::Product.all(permitted_params[:operator_id])
      if @products.success?
        render_data T2Airtime::Product.serialize @products.data,
                                                 @products.headers[:date]
      else
        render_error @products
      end
    end

    private

    def permitted_params
      filter_params.permit(:operator_id)
    end
  end
end
