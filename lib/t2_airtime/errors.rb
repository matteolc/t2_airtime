module T2Airtime
  # 0 	  Transaction successful	 											    Indicates the Top-up was successfully delivered to the recipient.
  # 101 	Destination MSISDN out of range 									Numbering plan not recognized: the destination/recipient number was not identified as to belonging to any operators covered by TransferTo. Re-check recipient number and/or escalate the case to the TransferTo Support Team for further investigation.
  # 104 	MSISDN in blacklist 												      Here MSISDN refers to both sender and recipient phone numbers which are blacklisted due to fraudulent activities.
  # 105 	Not enough credit on your account									Transaction failed due to insufficient funds in your account's prepaid balance. Please reload balance and try again.
  # 200 	Transaction canceled by Customer
  # 202 	Transaction canceled by TransferTo
  # 203 	Transaction incomplete 												    Transaction failed due to a technical issue. Please contact TransferTo Support Team for further investigation.
  # 204 	Destination Account is not prepaid or not valid		Transaction refused by the operator because the recipient phone number is not a valid prepaid account.
  # 207 	Transaction amount limit exceeded									Here limit refers to maximum amount defined for the destination MSISDN. There are some limitations set on the operator's side, not controlled by TransferTo. When one of these limits is reached, error code 207 will be returned. Some examples:
  #           •	Indosat Indonesia operator's end, the customer must wait at least 5 mins before sending another transfer to the same recipient account.
  #           •	Indian operators' end, the customer must wait 3 mins before sending another transfer of the same amount to the same recipient account.
  #           •	Orange Africa, the recipient account is limited to a maximum rechargeable amount of 30 Euros per week and 60 Euros per month.
  # 213 	Duplicated transaction 												    Transaction refused because it was submitted too closely after a preceding Top-up attempt.
  # 214 	Topup refused 														        Transaction refused by the operator for a reason that was not specified. Common reasons for these types of failures are: Recipient number not valid for recharge. Service outage temporarily faced on the operator. Please try again at a later time and/or contact the TransferTo Support Team if the problem persists.
  # 215 	Service to this destination operator is        		Transaction failed due to an outage and/or connection issue with the operator. Please try again at a later time and/or contact the TransferTo Support Team if the problem persists.
  #       temporarily unavailable
  # 216 	Destination number not activated									Transaction refused by the operator because the recipient number has not been activated.
  # 217 	Destination number expired 											  Transaction refused by the operator because the recipient number is no longer an active account.
  # 218 	Request timeout 													        Transaction timed-out and failed because of the long processing duration. Please try again at a later time and/or contact the TransferTo Support Team if the problem persists.
  # 219 	Key does not exist 													      Request failed because the key provided does not exist (error returned for get_id_from_key method requests only).
  # 221 	Fraud suspicion 													        Transaction refused and the recipient number flagged for suspicion of fraud, due to the number of consecutive Top-up requests within a short gap of time. The recipient phone number will be locked out from receiving any Top-up for a certain period of time, after which, the restriction will be automatically released.
  # 222 	Number barred from refill 											  This error code is returned when the recipient has been blocked from refill directly by the recipient's operator. It prevents TransferTo system from reloading his account. Recipient must call the operator’s customer service to unblock it.
  # 223 	ID not reserved 													        Transaction failed because the transaction ID specified in the request was not previously reserved.
  # 224 	Invalid length of destination MSISDN							Transaction failed because the recipient number length does not match (shorter or longer) the mobile number format of the country.
  # 230 	Recipient reached maximum topup number						This error is returned when a recipient reaches the maximum number of Top-up allowable in a certain gap of time.
  #           •	01 Day(s) => 10
  #           •	07 Day(s) => 15
  #           •	30 Day(s) => 40
  # 231 	Recipient reached maximum topup amount						This error is returned when a recipient reaches the maximum amount (in USD) of Top-up allowable in a certain gap of time.
  #           •	01 Day(s) => max 100 USD
  #           •	07 Day(s) => max 150 USD
  #           •	30 Day(s) => max 200 USD
  # 232 	Account reached maximum topup number							This error is returned when your account has reached its maximum number of Top-up allowable in a certain gap of time.
  # 233 	Account reached maximum topup amount							This error is returned when your account has reached its maximum amount (in USD) of Top-up allowable in a certain gap of time.
  # 241 	Account reached maximum daily topup amount				This error is returned when your account has reached its maximum amount (in USD) of Top-up allowable within a day.
  # 242 	Account reached maximum daily topup number				This error is returned when your account has reached its maximum number of Top-up allowable within a day.
  # 243 	Account reached maximum weekly topup amount				This error is returned when your account has reached its maximum amount (in USD) of Top-up allowable within a week.
  # 244	  Account reached maximum weekly topup number				This error is returned when your account has reached its maximum number of Top-up allowable within a week.
  # 245 	Account reached maximum monthly topup amount			This error is returned when your account has reached its maximum amount (in USD) of Top-up allowable within a month.
  # 246 	Account reached maximum monthly topup number			This error is returned when your account has reached its maximum number of Top-up allowable within a month.
  # 251 	Sender reached maximum daily topup amount					This error is returned when the sender has reached its maximum amount (in USD) of Top-up allowable within a day.
  # 252 	Sender reached maximum daily topup number					This error is returned when the sender has reached its maximum number of Top-up allowable within a day.
  # 253 	Sender reached maximum weekly topup amount				This error is returned when the sender has reached its maximum amount (in USD) of Top-up allowable within a week.
  # 254 	Sender reached maximum weekly topup number				This error is returned when the sender has reached its maximum number of Top-up allowable within a week.
  # 255 	Sender reached maximum monthly topup amount				This error is returned when the sender has reached its maximum amount (in USD) of Top-up allowable within a month.
  # 256 	Sender reached maximum monthly topup number				This error is returned when the sender has reached its maximum number of Top-up allowable within a day month.
  # 301 	Denomination not available 											  Denomination not available for this destination.
  # 310 	Denomination blocked 												      Transaction failed because the Top-up is no longer available on the operator's offer or on the account.
  # 320 	Requested amount out of range 										Transaction failed because the Top-amount request was not within the range of valid amounts.
  # 321 	Requested currency not allowed for this account		Transaction failed because the currency specified is not valid for the account.
  # 401 	Transaction ID not found or was not made     			No transaction was found with the ID specified (error returned for trans_info method requests only).
  #       by your account
  # 777 	Insufficient balance in your master account				Transaction failed because there are not enough funds in your master account.
  # 888 	Insufficient balance in your subaccount						Transaction failed because there are not enough funds in your sub-account.
  # 900 	Not enough information to process the topup				Transaction failed because some of the required fields in your Top-up request are missing/empty.
  # 901 	Invalid action 												        		Transaction failed because the action specified in <action> field of the request is not valid.
  # 902 	Invalid input_currency
  # 903 	Invalid output_currency
  # 904 	Invalid input_value
  # 905 	Invalid start_date
  # 906 	Invalid stop_date
  # 907 	Invalid transaction ID 											    	Transaction ID specified in the <reserved_id> of the Top-up request is not valid.
  # 908 	Account not configured for this service						Transaction failed because the account is not configured to carry out the requested action.
  # 909 	Invalid flag 											          			Transaction failed because the request included an invalid field/parameter.
  # 919 	All required argument not received								Transaction failed because the request is missing a mandatory field/parameter.
  # 921 	Wrong MD5 encoding 													      Transaction failed because the MD5 hash was not correct. Typically indicates that the password is incorrect.
  # 922 	Originating IP not allowed 							  				Transaction failed because the request originated from an IP that is not whitelisted for the account.
  # 923 	Key already used or invalid key value							Transaction failed because the key value included in the request was not unique and greater than the previous key used.
  # 926 	Account not active	 											      	Please contact your Account Manager.
  # 995 	Account not found	  												      Please enter and use a correct login.
  # 998 	System not available. Please retry later.					Transaction failed due to technical issues. Please contact TransferTo Support Team for further investigation.
  # 999 	Unknown error 												        		To be escalated to the TransferTo Support Team for further investigation.

  class Error < StandardError
    attr_reader :code

    def initialize(code, message = nil)
      @code = code.to_i
      super(message)
    end
  end

  class ConfigurationError < StandardError; end
end
