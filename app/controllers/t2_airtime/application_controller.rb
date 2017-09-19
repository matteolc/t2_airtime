module T2Airtime
  # Entry point
  class ApplicationController < ActionController::API
    protected


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
      }
    end

    def render_one(type)
      render json: {
        data: {
          type: type,
          id: params[:id]
        },
        status: :ok
      }
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
      }
    end
  end
end
