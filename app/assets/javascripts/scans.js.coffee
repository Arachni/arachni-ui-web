# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

scan_type_selected = false

showGoButton = () ->
    url = $('#scan_url').val()
    if scan_type_selected &&
    ((url.startsWith( 'http://' ) && !url.endsWith( 'http://' )) ||
    (url.startsWith( 'https://' ) && !url.endsWith( 'https://' )))
        $('#go-btn').show( 100 )
    else
        $('#go-btn').hide( 100 )

hadleAutoDispatcherNotice = ( type ) ->
    if type == 'remote'
        if $('#dispatcher').val() == 'auto'
            $('#auto-remote-dispatcher-notice').show( 50 )
        else
            $('#auto-remote-dispatcher-notice').hide( 50 )
    else if type == 'grid'
        if $('#master_dispatcher').val() == 'auto'
            $('#auto-master-remote-dispatcher-notice').show( 50 )
        else
            $('#auto-master-remote-dispatcher-notice').hide( 50 )

pickScanType = ( type ) ->
    $('#grid-alert').show( 50 )

    scan_type_selected = true

#    hadleAutoDispatcherNotice( type )
    showGoButton()
    switch type
        when 'direct'
            $('#scan_type').val( 'direct' )

            $('#dispatcher-grid').hide( 50 )
            $('#dispatcher-remote').hide( 50 )
            $('#direct').show
        when 'remote'
            $('#scan_type').val( 'remote' )

            $('#direct').hide( 50 )
            $('#dispatcher-grid').hide( 50 )
            $('#dispatcher-remote').show( 50 )
        when 'grid'
            $('#scan_type').val( 'grid' )

            $('#direct').hide( 50 )
            $('#dispatcher-remote').hide( 50 )
            $('#dispatcher-grid').show( 50 )

showSelectedProfile = () ->
    id = $('#scan_profile').val()
    $.ajax '/profiles/' + id + '.js',
        type: 'GET'
        dataType: 'html'
        success: ( data, textStatus, jqXHR ) ->
            $('#show-profile-container').html data
            $('#profile-edit-btn').attr( 'href', '/profiles/' + id + '/edit' )
            $('#show-profile').modal()

window.scanTableLoading = () ->
    $('#loading').show()

jQuery ->
    $('#direct-btn').click ->
        pickScanType( 'direct' )
    $('#remote-btn').click ->
        pickScanType( 'remote' )
    $('#grid-btn').click ->
        pickScanType( 'grid' )
    $('#scan_url').keyup ->
        showGoButton()
    $('#scan_url').blur ->
        showGoButton()
#    $('#dispatcher').change ->
#        hadleAutoDispatcherNotice( 'remote' )
#    $('#master_dispatcher').change ->
#        hadleAutoDispatcherNotice( 'grid' )
    $('#peek-profile').click ->
        showSelectedProfile()
    restoreAccordions()
    $('#active-scan-counter').bind 'refreshed', () ->
        if $(this).text() == '0'
            $(this).hide()
        else
            $(this).show()
