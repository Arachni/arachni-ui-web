# Copyright 2012 Tasos Laskos <tasos.laskos@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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

hadleAutoDispatcherNotice = ( type ) ->
    if type == 'remote'
        if $('#dispatcher').val() == 'auto'
            $('#auto-remote-dispatcher-notice').show( 50 )
        else
            $('#auto-remote-dispatcher-notice').hide( 50 )
    else if type == 'hpg'
        if $('#master_dispatcher').val() == 'auto'
            $('#auto-master-remote-dispatcher-notice').show( 50 )
        else
            $('#auto-master-remote-dispatcher-notice').hide( 50 )

pickScanType = ( type ) ->
    scan_type_selected = true

    $('#hpg-alert').show( 50 )

    hadleAutoDispatcherNotice( type )
    showGoButton()
    switch type
        when 'direct'
            $('#dispatcher-hpg').hide( 50 )
            $('#dispatcher-remote').hide( 50 )
            $('#direct').show( 50 )
        when 'remote'
            $('#direct').hide( 50 )
            $('#dispatcher-hpg').hide( 50 )
            $('#dispatcher-remote').show( 50 )
        when 'hpg'
            $('#direct').hide( 50 )
            $('#dispatcher-remote').hide( 50 )
            $('#dispatcher-hpg').show( 50 )

showSelectedProfile = () ->
    id = $('#scan-profile').val()
    $.ajax '/profiles/' + id + '.js',
        type: 'GET'
        dataType: 'html'
        success: ( data, textStatus, jqXHR ) ->
            $('#show-profile-container').html data
            $('#profile-edit-btn').attr( 'href', '/profiles/' + id + '/edit' )
            $('#show-profile').modal()


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
    $('#dispatcher').change ->
        hadleAutoDispatcherNotice( 'remote' )
    $('#master_dispatcher').change ->
        hadleAutoDispatcherNotice( 'hpg' )
    $('#peek-profile').click ->
        showSelectedProfile()
