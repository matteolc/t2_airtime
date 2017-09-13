module T2Airtime
  class Base

    attr_reader :user,
                :password,
                :url,
                :params

    def initialize(user, password, url)      
      @user, @password, @url, @params = user, password, url, {}
    end

    def self.api
        @api ||= new(
          ENV['T2_SHOP_USER'], 
          ENV['T2_AIRTIME_KEY'],
          "https://#{T2Airtime::AIRTIME_DN}.#{T2Airtime::DOMAIN}/#{T2Airtime::ENDPOINT}"
        )
    end

    def run_action(name, method=:get)
      request = T2Airtime::Request.new(@user, @password, @url, name, @params)
      request.run(method).on_complete do |reply|
        return T2Airtime::Reply.new(reply)
      end
    end
    
  end
end