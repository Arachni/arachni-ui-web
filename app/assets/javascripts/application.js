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
//= require jquery.turbolinks
//= require turbolinks
//= require bootstrap
//= require ./jqplot/jquery.jqplot.js
//= require_tree .

jQuery.fn.exists = function(){ return this.length > 0; }

$.expr[':'].icontains = function(obj, index, meta, stack){
    return (obj.textContent || obj.innerText || jQuery(obj).text() || '').
        toLowerCase().indexOf(meta[3].toLowerCase()) >= 0;
};

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

// Parent must have 'position: relative;'
function scrollToChild( parent, child ){
    parent = $(parent);
    child  = $(child);

    if( !child.exists() ) return;

    parent.scrollTop( parent.scrollTop() + child.position().top -
        parent.height() / 2 + child.height() / 2 );

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
        updatePage();
    }, "html" );
}

function restoreAccordions(){
    var accordionCookieName = 'activeAccordionGroup';

    aGroup = $.cookie( accordionCookieName, undefined, { path: '/' } );

    if( aGroup != null ){
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
    // Default open accordions.
    } else {
        // Scan statistics.
        $.cookie( accordionCookieName, ':statistics:', { path: '/' } );
    }

    $( ".collapse" ).on( 'shown', function(){
        aGroup = $.cookie( accordionCookieName, undefined, { path: '/' } );

        if( aGroup != null ) {
            aGroup += ':' + $( this ).attr( 'id' ) + ':';
        } else {
            aGroup = ':' + $( this ).attr( 'id' ) + ':';
        }

        $.cookie( accordionCookieName, aGroup, { path: '/' } );
    });

    $( ".collapse" ).on( 'hidden', function(){
        aGroup = $.cookie( accordionCookieName, undefined, { path: '/' } );

        if( aGroup != null ) {
            aGroup = aGroup.replace( new RegExp( ':' + $( this ).attr( 'id' ) + ':', 'g' ), '' );
            $.cookie( accordionCookieName, aGroup, { path: '/' } );
        }
    });
}

function restoreTabs() {
    var tabCookieName = 'activeTabGroup';

    elements = $('a[data-toggle="tab"]');
    aGroup   = $.cookie( tabCookieName, undefined, { path: '/' } );

    if( aGroup != null ) {
        elementIDs = aGroup.split( ':' );
        for( i = 0; i < elementIDs.length; i++ ) {
            element = $('a[href$="' + elementIDs[i] + '"]');

            if( element ) {
                element.tab( 'show' );
            }
        }
    }

    elements.on( 'shown', function( e ){
        id = e.target.href.split( '#' ).pop();

        aGroup = $.cookie( tabCookieName, undefined, { path: '/' } );

        if( aGroup != null ) {
            previous = e.relatedTarget.href.split( '#' ).pop();
            aGroup = aGroup.replace( new RegExp( ':' + previous + ':', 'g' ), '' );

            if( aGroup.indexOf( id ) == -1 ) {
                aGroup += ':' + id + ':';
            }
        } else {
            aGroup = ':' + id + ':';
        }

        $.cookie( tabCookieName, aGroup, { path: '/' } );
    });

}

function updatePage() {
    // Init all tooltips.
    $("[rel=tooltip]").tooltip();

    $('a[data-remote="true"]').each( function() {
        if( $(this).data( 'method' ) == undefined ){
            $(this).on( 'click', function () {
                history.pushState( null, document.title, this.href );
                return true;
            });
        }
    });

    restoreAccordions();
    restoreTabs();

    // Set the container's height to be at least as high as the affix'ed sidebar
    min_height  =
        $('#sidebar-affix').height() > $('#main-content').height() ?
            $('#sidebar-affix').height() : $('#main-content').height();

    curr_height = $('#content').height();

    if( curr_height < min_height ) {
        $('#content').height( min_height );
    }
}

var autoRefreshedElements = {};

function autoRefreshElement( selector ){
    var elem         = $(selector);
    var refresh_rate = elem.data( 'refresh-rate' ) ?
        elem.data( 'refresh-rate' ) : 5000;

    id = elem.attr( 'id' );

    // Initial fetch
    fetchAndFill( elem.data( 'refresh-url' ), elem );

    if( autoRefreshedElements[id] != undefined ) {
        clearInterval( autoRefreshedElements[id] );
    }

    autoRefreshedElements[id] = setInterval( function( ){
        // If the element no longer exists remove the refresher for it.
        if( !$('#' + elem.attr( 'id' )).exists() ) {
            clearInterval( autoRefreshedElements[elem.attr( 'id' )] );
            return;
        }

        fetchAndFill( elem.data( 'refresh-url' ), elem );
    }, refresh_rate );
}

function autoRefreshElements( selector ){
    $(selector).filter(function(){
        if( $(this).data('refresh-url') === undefined ) return;
        autoRefreshElement( this );
    });
}

function responsiveAdjust(){
    if( window.innerWidth <= 1058 ){

        if( $('#left-sidebar').exists() ) {
            $('#left-sidebar').attr( 'class', 'span2' );
            $('#main-content').attr( 'class', 'span10' )
        } else {
            $('#main-content').attr( 'class', 'span9' )
        }

        return;
    }

    if( window.innerWidth <= 1450 ){

        if( $('#left-sidebar').exists() ) {
            $('#left-sidebar').attr( 'class', 'span3' );
            $('#main-content').attr( 'class', 'span9' );
        } else {
            $('#main-content').attr( 'class', 'span12' )
        }

        return;
    }

    if( $('#left-sidebar').exists() ) {
        $('#left-sidebar').attr( 'class', 'span2' );
        $('#main-content').attr( 'class', 'span10' );
    } else {
        $('#main-content').attr( 'class', 'offset2 span8' );
    }
}

$(document).on( 'page:fetch', function( $ ) {
    loading();
});

$(document).ready( function( $ ) {
    updatePage();

    $( 'body' ).data( 'offset', $( 'header' ).height() + 45 );

    $( '.scroll' ).click( function( event ) {
        event.preventDefault();
        $( 'html,body' ).animate( { scrollTop: $( this.hash ).offset().top -
            $( 'header' ).height() - 10 }, 500 );
    });

    // Fade-out flash messages after a while.
    $( '#flash' ).delay( 500 ).fadeIn( 'normal', function() {
        $( this ).delay( 2500 ).fadeOut();
    });

    responsiveAdjust();
    $(window).resize( function(){
        responsiveAdjust();
    });

    // Perform AJAX refreshes on elements with a 'data-refresh-url' attribute
    // at set intervals.
    autoRefreshElements('div, span');

    // Disable turbolinks for fragments.
    $('a').each( function( i, e ){
        if( $(e).attr('href') == '#' ){
//            $(e).data( 'no-turbolink', '' );
            $(e).attr( 'href', 'javascript:void(0);' );
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
        $('#navigation-top ul.nav > li > a' ).each( function( i, e ){
            if( window.location.pathname.indexOf( $(e).attr( 'href' ) ) >= 0 ){
                $(e).parent().addClass( 'active' );
            }
        });

        // Hack to maintain dropdown menu state when they get refreshed
        // during a hover.
        $('#navigation-top .dropdown-menu' ).each( function( i, e ){
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

function loading(){
    $('#loading').show();
}

$(window).bind( "popstate", function () {
    $.getScript( location.href );
});

$(document).ajaxStop( function() {
    $("#loading").hide();
});
$(document).ajaxSuccess( function() {
    updatePage();
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
