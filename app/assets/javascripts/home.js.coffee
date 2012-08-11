# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@hideDispatcherSelect = () ->
    $('#dispatcher-hpg').hide()
    $('#dispatcher-remote').hide()

@showDispatcherSelect = ( type ) ->
    hideDispatcherSelect()
    if type == 'remote'
        $('#dispatcher-remote').show( 100 )
    else
        $('#dispatcher-hpg').show( 100 )

@showGoButton = () ->
    $('#go-btn').show( 100 )
