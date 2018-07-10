require 'devise'

module DeviseRailsApiAuthentication
  module Context
    extend ActiveSupport::Concern

    included do
      include Devise::Controllers::Helpers
      include ActionController::RespondWith
      before_action :authenticate_admin_from_token!
    end

    def authenticate_admin_from_token!
      return if Rails.env.development?

      if admin && Devise.secure_compare(admin.authentication_token, admin_token)
        warden.set_admin(admin, scope: :admin, store: false)
      else
        not_authenticated_error
      end
    end

    def admin_email
      request.headers['HTTP_X_ADMIN_EMAIL']
    end

    def admin_token
      request.headers['HTTP_X_ADMIN_TOKEN']
    end

    def not_authenticated_error
      response.headers['WWW-Authenticate'] = 'Token'
      head status: 401
    end

    def admin
      fail NotImplementedError
    end
  end
end
