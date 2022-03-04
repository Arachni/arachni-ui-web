// Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>
//
// This file is part of the Arachni WebUI project and is subject to
// redistribution and commercial restrictions. Please see the Arachni WebUI
// web site for more information on licensing and terms of use.
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
//= require bootstrap-transition
//= require bootstrap-collapse
//= require bootstrap-modal
//= require bootstrap-tooltip
//= require bootstrap-tab
//= require bootstrap-dropdown
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

Array.prototype.unique = function(){
    var u = {}, a = [];
    for(var i = 0, l = this.length; i < l; ++i){
        if(u.hasOwnProperty(this[i])) {
            continue;
        }
        a.push(this[i]);
        u[this[i]] = 1;
    }
    return a;
};

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

autoRefreshedElements = {};

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
    var aGroup = localStorage['accordions'];

    if( aGroup != null ){
        $( ".collapse" ).removeClass( 'in' );
        $( ".collapse" ).height( '0px' );

        var collapsibles = aGroup.split( ':' );
        for( i = 0; i < collapsibles.length; i++ ) {
            var collapsible = collapsibles[i];

            if( collapsible != '' && $( "#" + collapsible ) ){
                $( "#" + collapsible ).addClass( 'in' );
                $( "#" + collapsible ).height( 'auto' );
            }
        }
        // Default open accordions.
    } else {
        // Scan statistics.
        localStorage['accordions'] = ':statistics:';
    }

    $( ".collapse" ).on( 'shown', function(){
        aGroup = localStorage['accordions'];

        var id = ':' + $( this ).attr( 'id' ) + ':';

        if( aGroup != null ) {
            if( aGroup.indexOf(id) == -1 ){
                aGroup += id;
            }
        } else {
            aGroup = id;
        }

        localStorage['accordions'] = aGroup;
    });

    $( ".collapse" ).on( 'hidden', function(){
        // If there are any tabs open inside the accordion, close them, otherwise
        // the accordion will remain open.
        var openTabs = localStorage['tabs'];

        $('a[data-toggle="tab"]' ).each( function( i, e ) {
            id = e.href.split( '#' ).pop();
            openTabs = openTabs.replace( new RegExp( ':' + id + ':', 'g' ), '' );
            localStorage['tabs'] = openTabs;
        });

        aGroup = localStorage['accordions'];
        if( aGroup != null ) {
            localStorage['accordions'] =
                aGroup.replace( new RegExp( ':' + $( this ).attr( 'id' ) + ':', 'g' ), '' );
        }
    });
}

function restoreTabs() {
    var elements = $('a[data-toggle="tab"]');
    var aGroup   = localStorage['tabs'];

    if( aGroup != null ) {
        var elementIDs = aGroup.split( ':' );

        for( i = 0; i < elementIDs.length; i++ ) {
            var element = $('a[href$="' + elementIDs[i] + '"]');

            if( element ) {
                element.tab( 'show' );
            }
        }
    }

    elements.on( 'shown', function( e ){
        var id = e.target.href.split( '#' ).pop();

        aGroup = localStorage['tabs'];

        if( aGroup != null ) {
            var previous = e.relatedTarget.href.split( '#' ).pop();
            aGroup = aGroup.replace( new RegExp( ':' + previous + ':', 'g' ), '' );

            if( aGroup.indexOf( id ) == -1 ) {
                aGroup += ':' + id + ':';
            }
        } else {
            aGroup = ':' + id + ':';
        }

        localStorage['tabs'] = aGroup;
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
    var min_height  =
        $('#sidebar-affix').height() > $('#main-content').height() ?
            $('#sidebar-affix').height() : $('#main-content').height();

    var curr_height = $('#content').height();

    if( curr_height < min_height ) {
        $('#content').height( min_height );
    }
}

function autoRefreshElement( selector ){
    var elem         = $(selector);
    var refresh_rate = elem.data( 'refresh-rate' ) ?
        elem.data( 'refresh-rate' ) : 5000;

    var id = elem.attr( 'id' );

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
        $('#main-content').attr( 'class', 'span9' );
    } else {
        $('#main-content').attr( 'class', 'offset2 span8' );
    }
}

window.setupScrollHooks = function (){
    // fix sub nav on scroll
    var $win = $(window),
        $nav = $('.subnav' ),
        headerHeight = $('header').height(),
        navTop = headerHeight - $nav.height(),
        isFixed = 0;

    if( $nav.exists() ) {
        // hack sad times - holdover until rewrite for 2.1
        $nav.on( 'click', function () {
            if( !isFixed ) setTimeout( function () { $win.scrollTop($win.scrollTop() - 47) }, 10 );
        });
    }

    $win.scroll( function () {
        if( $nav ) {

            var i,
                // FireFox weirdness.
                scrollTop = document.documentElement.scrollTop || document.body.scrollTop;

            if( scrollTop >= navTop && !isFixed ) {
                isFixed = 1;
                $nav.addClass( 'subnav-fixed' );
                $nav.css( 'top', $('header').height() );
            } else if( scrollTop <= navTop && isFixed ) {
                isFixed = 0;
                $nav.removeClass( 'subnav-fixed' );
            }
        }

        var issueLegend = $("div#legend" );
        if( !issueLegend.exists() ) return;

        var charts = $('#charts');

        if (scrollTop + headerHeight >= $("#legend-reference" ).position().top) {
            issueLegend.addClass("stick");
            issueLegend.width( issueLegend.parent().width() );
        } else {
            issueLegend.removeClass("stick");
        }
    });
};

function loading(){
    $('#loading').show();
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
        var issueLegend = $("div#legend");
        issueLegend.width( issueLegend.parent().width() );

        responsiveAdjust();
    });

    // Perform AJAX refreshes on elements with a 'data-refresh-url' attribute
    // at set intervals.
    autoRefreshElements('div, span');

    var visibleDropdowns = [];
    var phoneMenuShown   = false;

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

    window.setupScrollHooks();
});

$(window).bind( "popstate", function () {
    $.getScript( location.href );
});

$(document).ajaxStop( function() {
    $("#loading").hide();
});
$(document).ajaxSuccess( function() {
    updatePage();
});
