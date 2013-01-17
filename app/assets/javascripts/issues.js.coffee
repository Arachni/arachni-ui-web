window.warned = false

renderResponse = ( container, html ) ->

    if ( !window.warned )
        confirm_render = window.confirm( "Rendering the response will also execute" +
            " any JavaScript code that might be included in the page," +
            " are you sure you want to continue?" )

        window.warned = confirm_render
        return if( !confirm_render)

    container.html( $( '<iframe class="rendered-response" ' +
                            'src="data:text/html;base64, ' + html + '" />' ) )

jQuery ->
    $( '#render-response-button' ).click ->
        renderResponse( $('#rendered-response-container .modal-body'), $(this).data( 'html' ) )
        $('#rendered-response-container').modal( 'show' )
