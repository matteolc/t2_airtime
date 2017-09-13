module T2Airtime
  class Util

    # A few fake phone numbers in Indonesia have been created and set up with available products of IDR 5000, 10000, 20000, 50000 and 100000:  
    # 628123456710: error code 0 for PIN based Top-up (successful transaction).
    # 628123456770: error code 0 for PIN less Top-up (successful transaction).
    # 628123456780: error code 204 (destination number is not a valid prepaid phone number).
    # 628123456781: error code 301 (input value out of range or invalid product).
    # 628123456790: error code 214 (transaction refused by the operator).
    # 628123456798: error code 998 (system not available, please retry later).
    # 628123456799: error code 999 (unknown error, please contact support).

    def self.test_numbers(num=0)
      numbers = [ "628123456710", "628123456770", "628123456780",
                  "628123456781", "628123456790", "628123456798",
                  "628123456799" ]
      num > 0 && num < 8 ? numbers[num-1] : numbers
    end 

    def self.format_time(timestr)
      Time.zone.parse(timestr).to_datetime.in_time_zone('UTC').iso8601
    end

    # Operator Logo URL
    def self.operator_logo_url(operator_aid, size=1)
      "https://#{T2Airtime::OPLOGO_DN}.#{T2Airtime::DOMAIN}/logo-#{operator_aid}-#{size}.png"    
    end         

  end
end