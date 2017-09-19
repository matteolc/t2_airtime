module T2Airtime
  # Proxy countries information
  class CountriesController < ApplicationController
    def index
      @countries = T2Airtime::Country.all
      if @countries.success?
        render_data T2Airtime::Country.serialize @countries.data,
                                                 @countries.headers[:date]
      else
        render_error @countries
      end
    end

    # noop
    def show
      render_one 'countries'
    end
  end
end
