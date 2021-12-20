# Copyright 2013-2022 Ecsypno LLC <http://www.ecsypno.com>
#
# This file is part of the Arachni WebUI project and is subject to
# redistribution and commercial restrictions. Please see the Arachni WebUI
# web site for more information on licensing and terms of use.

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.userScrolled = 0

window.scrollToSelectedGroup = () ->
    $('.scan-groups-list').scrollTop( window.userScrolled )

window.setupScanGroupHooks = () ->
    window.scrollToSelectedGroup()
    $('.scan-groups-list').scroll ->
        window.userScrolled = $('.scan-groups-list').scrollTop()

jQuery ->
    window.setupScanGroupHooks()
