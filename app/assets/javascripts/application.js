// Copyright 2012 Tasos Laskos <tasos.laskos@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// ----------------------------------------------------------------------------
//
// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require ./jqplot/jquery.jqplot.js
//= require_tree .

if( typeof String.prototype.startsWith != 'function' ) {
    String.prototype.startsWith = function( str ){
        return this.slice( 0, str.length ) == str;
    };
}

if( typeof String.prototype.endsWith != 'function' ) {
    String.prototype.endsWith = function( str ){
        return this.slice( -str.length ) == str;
    };
}

function fetchAndFill( url, element ){
    $.get( url, function( data ){
        element.html( data );
        element.trigger( 'refreshed' );
    }, "html" );
}

$(document).ready( function( $ ) {
    $( '.scroll' ).click( function( event ) {
        event.preventDefault();
        $( 'html,body' ).animate( { scrollTop: $( this.hash ).offset().top }, 500 );
    });
    $( '#flash' ).delay( 500 ).fadeIn( 'normal', function() {
        $( this ).delay( 2500 ).fadeOut();
    });

    $('div, span').filter(function(){
        if( $(this).data('refresh-url') !== undefined ){

            var elem         = $(this);
            var refresh_rate = elem.data( 'refresh-rate' ) ?
                elem.data( 'refresh-rate' ) : 5000;

            // Initial fetch
            fetchAndFill( elem.data( 'refresh-url' ), elem );

            setInterval( function( ){
                fetchAndFill( elem.data( 'refresh-url' ), elem );
            }, refresh_rate );
        }
    });

});

//$(document).ajaxStart( function() {
//    $("#loading").modal();
//}).ajaxStop( function() {
//        $("#loading").modal( 'hide' );
//    });

$(window).ready( function( $ ) {
    if( !$('.subnav' ) ) return;

    // fix sub nav on scroll
    var $win = $(window),
        $nav = $('.subnav' ),
        navTop = $('header').height() - $nav.height(),
        isFixed = 0;

    processScroll();

    // hack sad times - holdover until rewrite for 2.1
    $nav.on( 'click', function () {
        if( !isFixed ) setTimeout( function () { $win.scrollTop($win.scrollTop() - 47) }, 10 );
    });

    $win.on( 'scroll', processScroll );

    function processScroll() {
        var i, scrollTop = $win.scrollTop();
        if( scrollTop >= navTop && !isFixed ) {
            isFixed = 1;
            $nav.addClass( 'subnav-fixed' );
            $nav.css( 'top', $('header').height() );
        } else if( scrollTop <= navTop && isFixed ) {
            isFixed = 0;
            $nav.removeClass( 'subnav-fixed' );
        }
    }
});
