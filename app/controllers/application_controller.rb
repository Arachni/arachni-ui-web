=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

class ApplicationController < ActionController::Base
    before_action :wipe_storage

    protect_from_forgery
    rescue_from CanCan::AccessDenied do |exception|
        #redirect_to root_path, alert: exception.message

        # In case the request is perform via AJAX.
        flash[:alert] = exception.message
        render text: "<script> window.location = '#{root_path}'; </script>"
    end

    def self.storage
        @storage ||= {}
    end
    def storage
        self.class.storage
    end

    def wipe_storage
        storage.clear
    end

    def after_sign_in_path_for( resource )
        return super if Settings.welcomed?
        Settings.welcomed = true

        welcome_path
    end

end

