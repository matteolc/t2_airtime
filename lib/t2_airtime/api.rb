module T2Airtime
  class API < Base

    # Test the connection to the Airtime API. Can be used for keep-alive.
    def ping
      run_action :ping
    end

    # Returns the balance in your TransferTo account. 
    # This method shall not be used more than 24 times per day.     
    def account_info
      run_action :check_wallet
    end    

    # This method is used to recharge a destination number with a specified
    # denomination (“product” field).
    # This is the API’s most important action as it is required when sending
    # a topup to a prepaid account phone numberin a live! environment.
    #
    # parameters
    # ==========
    # msisdn
    # ------
    # The international phone number of the user requesting to credit
    # a TransferToAPI phone number. The format must contain the country code,
    # and will be valid with or without the ‘+’ or ‘00’ placed before it. For
    # example: “6012345678” or “+6012345678” or “006012345678” (Malaysia) are
    # all valid.
    #
    # product
    # -------
    # This field is used to define the remote product(often, the same as the
    # amount in destination currency) to use in the request.
    #
    # destination
    # -----------
    # This is the destination phone number that will be credited with the
    # amount transferred. Format is similar to “msisdn”.
    #
    # operator_id
    # -----------
    # It defines the operator id of the destination MSISDN that must be used
    # when treating the request. If set, the platform will be forced to use
    # this operatorID and will not identify the operator of the destination
    # MSISDN based on the numbering plan. It must be very useful in case of
    # countries with number portability if you are able to know the destination
    # operator. 

    # Most receiving operators (or carriers) are PIN less (direct top-up), meaning that the mobile phone of the 
    # recipient is recharged in real time. A few operators are however PIN based (mostly in the USA and UK). 
    # For  these  PIN  based  operators, a  PIN  code is  sent  by SMS  to  the  recipient, who  then  has  to manually 
    # complete the recharge process (usually by calling an IVR to redeem the PIN).

    # Name Type Description
    # pin_based String Returns “Yes” if PIN-based transactions. Else “No”.
    # pin_option_1 String Additional information. For example, it can describe how to use 
    # the PIN directly from handset (by entering a dedicated USSD code).
    # pin_option_2 String Additional information. For example, it can provide the operator refill website.
    # pin_option_3 String Additional information. For example, it can provide the operator refill call center.
    # pin_value Integer Value of the PIN.
    # pin_code Alphanumeric String Code of the PIN.
    # pin_ivr Integer IVR number of the PIN.
    # pin_serial Alphanumeric String Serial number of the PIN.
    # pin_validity String Validity of the PIN
    
    # By default, an SMS notification is sent to the recipient after every successful Top-up.
    # The default originating address for the SMS is “8888”.
    # The following is the default SMS which is translated into local languages for most of recipient countries:
    # Congratulations! You've received 
    # AMOUNT_CURRENCY from SENDER. Thank you for using
    # TransferTo. FREE_TEXT. 
    # • AMOUNT  CURRENCY  is  the  amount  that  has 
    # been sent with the currency.
    # • SENDER can be a name or a phone number.
    # • FREE_TEXT  is  the  content  of  the  field  named 
    # “sms” of the topup method.     

    def topup(msisdn, destination_msisdn, product, method='topup',
              reserved_id=nil, send_sms=true, sms=nil, sender_text=nil, operator_id=nil, 
              return_service_fee=1, delivered_amount_info=1, return_timestamp=1, return_version=1,
              return_promo=0)

      @params     = { 
          msisdn: msisdn, 
          destination_msisdn: destination_msisdn, 
          product: product 
      }
      self.oid = operator_id

      @params.merge({
        cid1: "", cid2: "", cid3: "",
        reserved_id: reserved_id,
        sender_sms: (sender_text ? "yes" : "no"),
        send_sms: (send_sms ? "yes" : "no"),
        sms: sms,
        sender_text: sender_text,
        delivered_amount_info: delivered_amount_info,
        return_service_fee: return_service_fee,
        return_timestamp: return_timestamp,
        return_version: return_version,
        return_promo: return_promo
      })

      run_action method
      #{
      #  requesting_msisdn:         response[:msisdn],
      #  destination_msisdn:        response[:destination_msisdn],       
      #  product_sent:              response[:actual_product_sent].to_i,
      #  local_amount:              response[:local_info_amount],
      #  local_value:               response[:local_info_value],
      #  local_currency_code:       response[:local_info_currency],       
      #  transaction_status:        response[:error_txt], 
      #  operation_result:          response[:error_code],
      #  operation_info:            response[:info_txt],       
      #  transaction_api_id:        response[:transactionid].to_i,
      #  country_api_id:            response[:countryid].to_i,
      #  operator_api_id:           response[:operatorid].to_i,
      #  product_api_id:            response[:product_requested].to_i,       
      #  originator_currency_code:  response[:originating_currency],
      #  destination_currency_code: response[:destination_currency],       
      #  wholesale_price:           response[:wholesale_price],
      #  retail_price:              response[:retail_price],
      #  service_fee:               response[:service_fee]
      #}       
    end

    # This method is used to retrieve various information of a specific MSISDN
    # (operator, country…) as well as the list of all products configured for
    # your specific account and the destination operator of the MSISDN.
    # Returns relevant information on a MSISDN (operator, country…) as well as the 
    # list of products configured for your account and the destination operator 
    # linked to that MSISDN. Allows to check if a MSISDN is subjected to a promotion
    #
    # destination_msisdn
    # Destination MSISDN (usually recipient phone number). This is the destination phone number that will 
    # be credited with the amount transferred. Format is similar to “msisdn” and restricted to international phone number only.     
    # delivered_amount_info
    # Setting this to “1” will return the fields local_info_amount_list,local_info_currency and local_info_value_list in the API response. 
    # Blank or “no” if you do not want this returned.
    # return_service_fee 
    # Setting this to “1” will return the field service_fee_list in the API response. Blank or “0” if you do not want it returned.
    # operatorid
    # Operator ID of the receiving operator that must be used when treating the request. If 
    # set, the platform will be forced to use this operator ID and will not identify the operator of 
    # the destination MSISDN based on the numbering plan. It is very useful in case of countries with number
    # portability if you are able to know the destination operator.        
    # return_promo
    # Setting this to “1” will return the current  promotion related to the transaction’s operator.    
    def msisdn_info(destination_msisdn, 
                    operator_id=nil, 
                    delivered_amount_info=1, return_service_fee=1, return_promo=1)
      @params = {
        destination_msisdn: destination_msisdn,
        delivered_amount_info: delivered_amount_info,
        return_service_fee: return_service_fee,
        return_promo: return_promo
      }
      self.oid = operator_id
      run_action :msisdn_info
    end
    
    # This method is used to reserve an ID in the system. This ID can then be
    # used in the “topup” or “simulation” requests.
    # This way, your system knows the ID of the transaction before sending the
    # request to TransferTo (else it will only be displayed in the response).   
    def reserve_id
      run_action :reserve_id
    end    

    # This method is used to retrieve the list of transactions performed within
    # the date range by the MSISDN if set. Note that both dates are included
    # during the search.
    #
    # parameters
    # ==========
    # msisdn
    # ------
    # The format must be international with or without the ‘+’ or ‘00’:
    # “6012345678” or “+6012345678” or “006012345678” (Malaysia)
    #
    # destination_msisdn
    # ------------------
    # The format must be international with or without the ‘+’ or ‘00’:
    # “6012345678” or “+6012345678” or “006012345678” (Malaysia)
    #
    # code
    # ----
    # The error_code of the transactions to search for. E.g “0” to search for
    # only all successful transactions. If left empty, all transactions will be
    # returned(Failed and successful).
    #
    # start_date
    # ----------
    # Defines the start date of the search. Format must be YYYY-MM-DD.
    #
    # stop_date
    # ---------
    # Defines the end date of the search (included). Format must be YYYY-MM-DD.
    def transaction_list(start=(Time.now-24.hours), stop=Time.now, msisdn=nil, destination=nil, code=nil)
      @params[:code]               = code unless code
      @params[:msisdn]             = msisdn unless msisdn
      @params[:stop_date]          = to_yyyymmdd(stop)
      @params[:start_date]         = to_yyyymmdd(start)
      @params[:destination_msisdn] = destination unless destination
      run_action :trans_list
    end

    # Retrieve available information on a specific transaction. Please note that values of “input_value” and
    # “debit_amount_validated” are rounded to 2 digits after the comma but are
    # the same as the values returned in the fields “input_value” and
    # “validated_input_value” of the “topup” method response.        
    def transaction_info(id)
      @params = { transactionid: id }
      run_action :trans_info
    end    

    # This method is used to retrieve the ID of a transaction previously
    # performed based on the key used in the request at that time.
    def get_id_from_key(key)
      @params = { from_key: key }
      run_action :get_id_from_key
    end    

    # These methods are used to retrieve coverage and pricelist offered to you.
    # parameters
    # ==========
    # info_type
    # ---------
    #   i) “countries”: Returns a list of all countries offered to you
    #  ii) “country”  : Returns a list of operators in the country
    # iii) “operator” : Returns a list of wholesale and retail price for the operator
    #
    # content
    # -------
    #   i) Not used if info_type = “countries”
    #  ii) countryid of the requested country if info_type = “country”
    # iii) operatorid of the requested operator if info_type = “operator”
    def price_list(info_type, content=nil)
      @params[:info_type] = info_type
      content && @params[:content] = content
      run_action :pricelist
    end

    # Convenience method to get the country list
    def country_list() price_list('countries') end

    # Convenience method to get the operators list for a given country
    # @country_aid the airtime id of the country
    def operator_list(country_aid) price_list('country', country_aid) end 
        
    # Convenience method to get the product list for a given operator
    # @operator_aid the airtime id of the operator    
    def product_list(operator_aid) price_list('operator', operator_aid) end 

    private

    def oid=(operator_aid)
      operator_aid.is_a?(Integer) && @params[:operatorid] = Integer(operator_aid)
    end

    def to_time(time)
      case time.class.name
      when "String"  then return Time.parse(time)
      when "Integer" then return Time.at(time)
      when "Time"    then return time
      else raise ArgumentError
      end
    rescue
      Time.now
    end

    def to_yyyymmdd(time)
      to_time(time).strftime("%Y-%m-%d")
    end    

  end
end
