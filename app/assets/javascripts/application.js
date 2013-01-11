// Copyright 2013 Tasos Laskos <tasos.laskos@gmail.com>
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

if( typeof Array.prototype.contains != 'function' ) {
    Array.prototype.contains = function(obj) {
        var i = this.length;
        while (i--) {
            if (this[i] === obj) {
                return true;
            }
        }
        return false;
    };
}

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

// Request the given url and place the response body as HTML inside the
// given element.
function fetchAndFill( url, element ){
    $.get( url, function( data ){
        element.trigger( 'refresh' );

        if( element.data( 'refresh-type' ) == 'js' ){
            $.globalEval( data );
        } else {
            element.html( data );
        }

        element.trigger( 'refreshed' );
    }, "html" );
}

function restoreAccordions(){
    aGroup = $.cookie( 'activeAccordionGroup' );

    if( aGroup ){
        $( ".collapse" ).removeClass( 'in' );
        $( ".collapse" ).height( '0px' );

        collapsibles = aGroup.split( ':' );
        for( i = 0; i < collapsibles.length; i++ ) {
            collapsible = collapsibles[i];

            if( collapsible != '' && $( "#" + collapsible ) ){
                $( "#" + collapsible ).addClass( 'in' );
                $( "#" + collapsible ).height( 'auto' );
            }
        }
    }

    $( ".collapse" ).on( 'shown', function(){
        aGroup = $.cookie( 'activeAccordionGroup' );
        aGroup += ':' + $( this ).attr( 'id' ) + ':';
        $.cookie( 'activeAccordionGroup', aGroup );
    });

    $( ".collapse" ).on( 'hidden', function(){
        aGroup = $.cookie( 'activeAccordionGroup' );
        aGroup = aGroup.replace( new RegExp( ':' + $( this ).attr( 'id' ) + ':', 'g' ), '' );
        $.cookie( 'activeAccordionGroup', aGroup );
    });
}

$(document).ready( function( $ ) {
    restoreAccordions();

    // Init all tooltips.
    $("[rel=tooltip]").tooltip();

    $( 'body' ).data( 'offset', $( 'header' ).height() + 45 );

    $( '.scroll' ).click( function( event ) {
        event.preventDefault();
        $( 'html,body' ).animate( { scrollTop: $( this.hash ).offset().top - $( 'header' ).height() - 10 }, 500 );
    });

    // Fade-out flash messages after a while.
    $( '#flash' ).delay( 500 ).fadeIn( 'normal', function() {
        $( this ).delay( 2500 ).fadeOut();
    });

    // Perform AJAX refreshes on elements with a 'data-refresh-url' attribute
    // at set intervals.
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

    var visibleDropdowns = [];
    var phoneMenuShown = false;

    // This gets called just before the navbar is refreshed via AJAX.
    $('#navigation-top').bind( 'refresh', function(){

        phoneMenuShown = $('#phone-menu ul.dropdown-menu' ).is( ':visible' );

        visibleDropdowns = [];
        $('.dropdown-menu' ).each( function( i, e ){
            if( $(e).is( ":visible" ) && $(e).attr( 'id' ) != undefined ){
                visibleDropdowns.push( $(e).attr( 'id' ) );
            }
        });
    });

    // This gets called after the navbar has been refreshed via AJAX.
    $('#navigation-top').bind( 'refreshed', function(){

        if( phoneMenuShown ){
            $('#phone-menu ul.dropdown-menu' ).dropdown( 'toggle' );
        }

        // Set the active section in the navbar.
        //
        // Since the navbar gets refreshed via AJAX we can't figure this out on
        // the server-side because the controller will always be irrelevant.
        $('ul.nav > li > a' ).each( function( i, e ){
            if( window.location.pathname.split( '/' )[1] == $(e).attr( 'href' ).split( '/' )[1] ){
                $(e).parent().addClass( 'active' );
            }
        });

        // Hack to maintain dropdown menu state when they get refreshed
        // during a hover.
        $('.dropdown-menu' ).each( function( i, e ){
            if( visibleDropdowns.contains( $(e).attr( 'id' ) ) ){
                $(e).show();
                $(e).parent().hover( function(){
                    $(e).show();
                }, function(){
                    $(e).hide();
                });
            }
        });

        visibleDropdowns = [];
    });

});

$(document).ajaxStart( function() {
//    $("#loading").modal();
}).ajaxStop( function() {
        $("#loading").hide();
    });

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
