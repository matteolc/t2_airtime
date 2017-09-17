module T2Airtime
  # Proxy transactions information
  class TransactionsController < ApplicationController
    def index
      @transactions = T2Airtime::API.api.transaction_list parse_time_param(permitted_params[:start]),
                                                          parse_time_param(permitted_params[:stop]),
                                                          permitted_params[:msisdn],
                                                          permitted_params[:destination],
                                                          permitted_params[:code]
      if @transactions.success?
        render_data T2Airtime::Transaction.serialize @transactions.data
      else
        render_error T2Airtime::Error.new @transactions.error_code,
                                          @transactions.error_message
      end
    end

    def show
      @transaction = T2Airtime::Transaction.get(params[:id])
      if @transaction.success?
        render_data T2Airtime::Transaction.serialize_one @transaction.data,
                                                         @transaction.headers[:date]
      else
        render_error T2Airtime::Error.new @transaction.error_code,
                                          @transaction.error_message
      end
    end

    private

    def parse_time_param(timestr)
      Time.zone.parse(timestr)
    rescue
      nil
    end    


    def permitted_params
      filter_params.permit(
        :msisdn,
        :destination,
        :code,
        :start,
        :stop
      )
    end
  end
end
