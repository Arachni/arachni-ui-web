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

updateElementsVisibility = () ->
    if $( '#issue_false_positive').is( ':checked' )
            $( '#false-positive-report-nudge' ).show( 'fast' )
            $( '#issue_requires_verification' ).prop( 'disabled', true )
            $( '#issue_verified' ).prop( 'disabled', true )
            $( '#issue_verification_steps' ).prop( 'disabled', true )
        else
            $( '#false-positive-report-nudge' ).hide( 'fast' )
            $( '#issue_requires_verification' ).prop( 'disabled', false )
            $( '#issue_verified' ).prop( 'disabled', false )
            $( '#issue_verification_steps' ).prop( 'disabled', false )

    if $( '#issue_requires_verification').is( ':checked' )
        $( '#verification-container' ).show( 'fast' )
        $( '#issue_false_positive' ).prop( 'disabled', true )
    else
        $( '#verification-container' ).hide( 'fast' )
        $( '#issue_false_positive' ).prop( 'disabled', false )

jQuery ->
    $('#render-response-button' ).click ->
        renderResponse( $('#rendered-response-container .modal-body'), $(this).data( 'html' ) )
        $('#rendered-response-container').modal( 'show' )
    $('#issue-tabs a[href$="technical-details"]').on 'shown', () ->
        $('#sidenav').show()
    $('#issue-tabs a[href$="discussion"]').on 'shown', () ->
        $('#sidenav').hide()
    $('#issue-tabs a[href$="verification"]').on 'shown', () ->
        $('#sidenav').hide()
    $('#issue-tabs a[href$="manage"]').on 'shown', () ->
        $('#sidenav').hide()
    $('#issue_false_positive').change ->
        updateElementsVisibility()
    $('#issue_requires_verification').change ->
        updateElementsVisibility()
    updateElementsVisibility()
