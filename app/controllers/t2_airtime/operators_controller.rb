module T2Airtime
  # Proxy operators information
  class OperatorsController < ApplicationController
    def index
      @operators = T2Airtime::Operator.all(permitted_params[:country_id])
      if @operators.success?
        render_data T2Airtime::Operator.serialize @operators.data,
                                                  @operators.headers[:date]
      else
        render_error T2Airtime::Error.new @operators.error_code,
                                          @operators.error_message
      end
    end

    # noop
    def show
      render_one 'operators'
    end

    private

    def permitted_params
      filter_params.permit(:country_id)
    end
  end
end
