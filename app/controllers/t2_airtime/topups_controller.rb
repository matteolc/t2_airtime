module T2Airtime
    # Help with topup
    class TopupsController < ApplicationController
      def msisdn_info
        @msisdn_info = T2Airtime::Msisdn.info permitted_params[:destination_number]
        if @msisdn_info.success?
          render_data T2Airtime::Msisdn.serialize @msisdn_info.data,
                                                  @msisdn_info.headers[:date]
        else 
          render_error T2Airtime::Error.new @msisdn_info.error_code,
                                            @msisdn_info.error_message
        end
      end

      def reserve_id
        @reserve_id = T2Airtime::API.api.reserve_id
        if @reserve_id.success?
          render_data @reserve_id.data
        else
          render_error T2Airtime::Error.new @reserve_id.error_code,
                                            @reserve_id.error_message
        end
      end      

      def topup
        @topup = T2Airtime::API.api.topup permitted_params[:msisdn],
                                          permitted_params[:destination_number],
                                          permitted_params[:product],
                                          permitted_params[:method],
                                          permitted_params[:reserved_id],
                                          permitted_params[:send_sms],
                                          permitted_params[:sms],
                                          permitted_params[:sender_text],
                                          permitted_params[:cid1],
                                          permitted_params[:cid2],
                                          permitted_params[:cid3]

        if @topup.success?
          render_data T2Airtime::Topup.serialize @topup.data
        else
          render_error T2Airtime::Error.new @topup.error_code,
                                            @topup.error_message
        end
      end      
    
      private
    
  
      def permitted_params
        params.permit(
            :msisdn,        
            :destination_number,
            :product,
            :method,
            :reserved_id,
            :send_sms,
            :sms,
            :sender_text,
            :cid1,
            :cid2,
            :cid3
        )
      end
    end
  end
  