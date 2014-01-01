=begin
    Copyright 2013-2014 Tasos Laskos <tasos.laskos@gmail.com>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
=end

require 'socket'
require 'timeout'

module ApplicationHelper
    include ::FrameworkHelper

    def params_to_hash( params )
        return {} if !params

        params.inject({}) do |h, (k, v)|
            h[k] = v.is_a?( ActionController::Parameters ) ? params_to_hash( v ) : v
            h
        end
    end

    def fade_out_messages?
        !@do_not_fade_out_messages
    end

    def do_not_fade_out_messages
        @do_not_fade_out_messages = true
    end

    def my_paginate( rows, opts = {} )
        s = paginate( rows, opts )
        #s.gsub!( /(&amp;|\?)partial=true/, '' ) if !opts[:partial]
        s.html_safe
    end

    def render_partial?
        params[:partial] == 'true'
    end

    def object_for( key, obj = nil )
        if obj
            ApplicationController.storage[key] = obj
        else
            ApplicationController.storage[key]
        end
    end

    def pop_object_for( key )
        ApplicationController.storage.delete( key )
    end

    def object_for?( key )
        ApplicationController.storage.include? key
    end

    def m( string )
        GitHub::Markdown.render( string ).html_safe
    end

    def truncate_html( html, length = 500, append = ' [...]' )
        return html if html.size <= length

        Nokogiri::HTML.fragment( html[0..length] + append, 'utf-8' ).
            to_html.html_safe
    end

    def host_reachable?( host, port, seconds = 5 )
        Timeout::timeout( seconds ) do
            begin
                TCPSocket.new( host, port ).close
                true
            rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError
                false
            end
        end
    rescue Timeout::Error
        false
    end

    extend self
end
