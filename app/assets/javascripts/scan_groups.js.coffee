# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.scrollToSelectedGroup = () ->
    scrollToChild( '.scan-groups-list', '.scan-groups-list li.active' )

jQuery ->
    window.scrollToSelectedGroup()
