module T2Airtime
    class AirtimeController < ActionController::API
  
      def account
         reply = T2Airtime::API.api.account_info
         if reply.success?
            render_data T2Airtime::Account.serialize reply.data, 
                                                     reply.headers[:date]
         else
            render_error T2Airtime::Error.new reply.error_code, 
                                              reply.error_message
         end       
      end
  
  
      def countries
         reply = T2Airtime::API.api.country_list
         if reply.success?
            render_data T2Airtime::Country.serialize reply.data, 
                                                     reply.headers[:date]
         else
            render_error T2Airtime::Error.new reply.error_code, 
                                              reply.error_message
         end
      end
  
      def operators
         reply = T2Airtime::API.api.operator_list(params[:id])
         if reply.success?
            render_data T2Airtime::Operator.serialize reply.data, 
                                                      reply.headers[:date]
         else
            render_error T2Airtime::Error.new reply.error_code, 
                                              reply.error_message
         end
      end    
  
      def products
         reply = T2Airtime::API.api.product_list(params[:id])
         if reply.success?
            render_data T2Airtime::Product.serialize reply.data,
                                                     reply.headers[:date]
         else
            render_error T2Airtime::Error.new reply.error_code, 
                                              reply.error_message
         end
      end 
      
      def transactions
         reply = T2Airtime::API.api.transaction_list parse_time_param(params[:start]), 
                                                     parse_time_param(params[:stop]), 
                                                     params[:msisdn], 
                                                     params[:destination], 
                                                     params[:code]
         if reply.success?
            render_data T2Airtime::Transaction.serialize reply.data
         else
            render_error T2Airtime::Error.new reply.error_code, 
                                              reply.error_message
         end
      end 
  
      def transaction
         reply = T2Airtime::API.api.transaction_info(params[:id])
         if reply.success?
            render_data T2Airtime::Transaction.serialize_one reply.data,
                                                             reply.headers[:date]
         else
            render_error T2Airtime::Error.new reply.error_code, 
                                              reply.error_message
         end
      end     
      
      protected
  
      def parse_time_param(timestr)
        begin 
          Time.zone.parse(timestr)
        rescue
          nil
        end
      end
  
  
      def render_data(data)
            render json: {              
                data: data,
                status: :ok
            }
      end    
  
      def render_error(error)
            render json: {
                errors: [{
                  code: error.code,
                  detail: error.message,
                  title: "Error!"
                }],
                status: :bad_request
            }
      end
  
  
    end
  end        