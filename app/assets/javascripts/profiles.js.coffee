# Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>
#
# This file is part of the Arachni WebUI project and is subject to
# redistribution and commercial restrictions. Please see the Arachni WebUI
# web site for more information on licensing and terms of use.

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

searchModules = ( val ) ->
    $(".profile-checks").show()

    if( val != '' )
        $(".profile-checks:not(:icontains(" + val + "))").hide()
    else
        $(".profile-checks").show()

jQuery ->
    $('#profiles input#search').keyup ->
        searchModules $(this).val()

    $('#profiles button.check').click ->
        $('.profile-checks input:visible:checkbox').attr('checked','checked')
        false
    $('#profiles button.uncheck').click ->
        $('.profile-checks input:visible:checkbox').removeAttr('checked')
        false
