# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

scan_type_selected = false

showGoButton = () ->
    url = $('#url').val()
    if scan_type_selected &&
    ((url.startsWith( 'http://' ) && !url.endsWith( 'http://' )) ||
    (url.startsWith( 'https://' ) && !url.endsWith( 'https://' )))
        $('#go-btn').show( 100 )
    else
        $('#go-btn').hide( 100 )

pickScanType = ( type ) ->
    scan_type_selected = true

    showGoButton()
    switch type
        when 'direct'
            $('#dispatcher-hpg').hide( 50 )
            $('#dispatcher-remote').hide( 50 )
        when 'remote'
            $('#dispatcher-hpg').hide( 50 )
            $('#dispatcher-remote').show( 50 )
        when 'hpg'
            $('#dispatcher-remote').hide( 50 )
            $('#dispatcher-hpg').show( 50 )

jQuery ->
    $('#direct-btn').click ->
        pickScanType( 'direct' )
    $('#remote-btn').click ->
        pickScanType( 'remote' )
    $('#hpg-btn').click ->
        pickScanType( 'hpg' )
    $('#url').keyup ->
        showGoButton()
    $('#url').blur ->
        showGoButton()
