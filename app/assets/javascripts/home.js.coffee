# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

scan_type_selected = false

hideDispatcherSelect = () ->
    scan_type_selected = true
    $('#dispatcher-hpg').hide( 50 )
    $('#dispatcher-remote').hide( 50 )

showDispatcherSelect = ( type ) ->
    hideDispatcherSelect()
    if type == 'remote'
        $('#dispatcher-remote').show( 100 )
    else
        $('#dispatcher-hpg').show( 100 )

showGoButton = () ->
    url = $('#url').val()
    if scan_type_selected &&
    ((url.startsWith( 'http://' ) && !url.endsWith( 'http://' )) ||
    (url.startsWith( 'https://' ) && !url.endsWith( 'https://' )))
        $('#go-btn').show( 100 )
    else
        $('#go-btn').hide( 100 )

jQuery ->
    $('#direct-btn').click ->
        hideDispatcherSelect()
        showGoButton()
    $('#remote-btn').click ->
        showDispatcherSelect( 'remote' )
        showGoButton()
    $('#hpg-btn').click ->
        showGoButton()
        showDispatcherSelect( 'hpg' )
    $('#url').keyup ->
        showGoButton()
    $('#url').blur ->
        showGoButton()
