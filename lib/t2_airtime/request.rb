module T2Airtime
  class Request

    def initialize(user, password, url, name, params)
      @user   = user || ""
      @pass   = password || ""
      @conn = Faraday.new(url: url) do |faraday|
        faraday.request  :url_encoded
        faraday.adapter  :net_http        
      end
      reset
      @name = name
      add_param :action, name
      @params.merge!(params)     
    end

    def reset
      @params = {}
      authenticate
    end

    def authenticate
      time = Time.now.to_i.to_s
      add_param :key,   time
      add_param :md5,   md5_hash(@user + @pass + time)
      add_param :login, @user
    end

    def add_param(key, value) @params[key.to_sym] = value end

    def key() @params[:key] end

    def get?() @params[:method] == :get end

    def post?() @params[:method] == :post end

    # More than 99.5% of the transactions are currently processed within a few seconds. 
    # However, it may happen in some rare cases that a transaction takes longer to be processed by the receiving
    # operator due to congested system on their end for instance.
    # TransferTo guarantees that transactions not processed within 600 seconds will not be charged, whatever 
    # the final status of the transaction (successful or not). In addition, TransferTo is operating a real time system;
    # therefore, the status returned in the Top-up response is final and will not change.
    # To  ensure  that  your  system  captures  successfully  the  status  of  all  transactions  especially  the  longest 
    # ones, it is advised to either set up a high timeout value of 600seconds to be on the safe side (TCP connection
    # could potentially be opened for a long time in this case) or to set up a mechanism to check on 
    # the status (to do so, you can call the trans_info method to retrieve the final status of a transaction).
    # In case of timeout, both methods reserve_id and get_id_from_key of the API could be useful to identify 
    # the ID of the transaction (we recommend to either send a reserve_id request and to use the ID returned 
    # in the response in the subsequent top-up request so that you know in advance the ID of the transaction).    
    def run(method = :get)
      add_param :method, method
      @conn.send(method, "/#{T2Airtime::ENDPOINT}", @params) do |req|
        req.options = { timeout: 600, open_timeout: 600 }
      end
    end

    private

    def md5_hash(str)
      (Digest::MD5.new << str).to_s
    end


  end
end
