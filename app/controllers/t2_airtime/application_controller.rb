module T2Airtime
  # Entry point
  class ApplicationController < ActionController::API

    include ActionController::HttpAuthentication::Token::ControllerMethods
    before_action :authenticate

    protected

    def authenticate
      authenticate_token || render_unauthorized
    end
  
    def authenticate_token
      authenticate_with_http_token do |token, options|
        tokenHash === token
      end
    end

    def tokenHash
      OpenSSL::HMAC.hexdigest 'sha256', 
                              ENV['API_KEY'],
                              ENV['API_TOKEN']
    end    
  
    def render_unauthorized
      self.headers['WWW-Authenticate'] = 'Token realm="Application"'
      render json: {        
        errors: [{
          code: 401,
          detail: 'Invalid Token',
          title: 'Unauthorized!'
        }]
      },        
      status: :unauthorized
    end    

    def filter_params
      begin
        params.require(:filter) 
      rescue
        ActionController::Parameters.new({})
      end
    end    

    def render_data(data)
      render json: {
        data: data,
        meta: {
          'record-count' => data.length
        },
        status: :ok
      },
      status: :ok
    end

    def render_one(type)
      render json: {
        data: {
          type: type,
          id: params[:id]
        },
        status: :ok
      },
      status: :ok
    end

    def render_error(response)
      error = T2Airtime::Error.new response.error_code,
      response.error_message      
      render json: {
        errors: [{
          code: error.code,
          detail: error.message,
          title: 'Error!'
        }],
        status: :bad_request
      },
      status: :bad_request
    end
  end
end
