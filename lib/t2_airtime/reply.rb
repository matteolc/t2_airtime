module T2Airtime
  class Reply
    def initialize(reply)
      @response = Hash(reply)
    end

    def data
      hash = {}
      @response[:body].lines.each do |line|
        key, value = line.strip.split '='
        hash[key.to_sym] = key == 'error_code' ? Integer(value) : value
      end; hash
    end

    def information
      data.reject do |key, _value|
        %i[authentication_key error_code error_txt].include?(key)
      end
    end

    def success?
      status == 200 && error_code == 0
    end

    def status
      @response[:status]
    end

    def error_code
      data[:error_code]
    end

    def error_message
      data[:error_txt]
    end

    def url
      (@response[:url]).to_s
    end

    def message
      information[:info_txt]
    end

    def auth_key
      data[:authentication_key]
    end

    def headers
      @response[:response_headers]
    end

    def raw
      @response[:body]
    end
  end
end
