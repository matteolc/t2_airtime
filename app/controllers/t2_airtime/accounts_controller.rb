module T2Airtime
  # Proxy accounts information
  class AccountsController < ApplicationController
    def show
      @account = T2Airtime::Account.get
      if @account.success?
        render_data T2Airtime::Account.serialize @account.data,
                                                 @account.headers[:date]
      else
        render_error @account
      end
    end
  end
end
