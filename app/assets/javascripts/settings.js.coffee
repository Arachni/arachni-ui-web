# Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>
#
# This file is part of the Arachni WebUI project and is subject to
# redistribution and commercial restrictions. Please see the Arachni WebUI
# web site for more information on licensing and terms of use.

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

searchModules = ( val ) ->
    $("#settings ").show()

    if( val != '' )
        $("#settings .check:not(:icontains(" + val + "))").hide()
    else
        $("#settings .check").show()

jQuery ->
    $('#settings input#search').keyup ->
        searchModules $(this).val()

    $('#settings #profile button.check').click ->
        $('#settings .check input:visible:checkbox').attr('checked','checked')
        false
    $('#settings #profile button.uncheck').click ->
        $('#settings .check input:visible:checkbox').removeAttr('checked')
        false
