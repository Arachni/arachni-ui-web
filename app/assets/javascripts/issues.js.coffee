# Copyright 2013 Tasos Laskos <tasos.laskos@gmail.com>
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
    if $( '#issue_fixed').is( ':checked' )
        $( '#issue_false_positive' ).prop( 'disabled', true )
        $( '#issue_requires_verification' ).prop( 'disabled', true )
        $( '#issue_verified' ).prop( 'disabled', true )
        $( '#issue_verification_steps' ).prop( 'disabled', true )
    else
        $( '#issue_false_positive' ).prop( 'disabled', false )
        $( '#issue_requires_verification' ).prop( 'disabled', false )
        $( '#issue_verified' ).prop( 'disabled', false )
        $( '#issue_verification_steps' ).prop( 'disabled', false )

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
        $('#references').hide()
    $('#issue-tabs a[href$="discussion"]').on 'shown', () ->
        $('#sidenav').hide()
        $('#references').hide()
    $('#issue-tabs a[href$="verification"]').on 'shown', () ->
        $('#sidenav').hide()
        $('#references').hide()
    $('#issue-tabs a[href$="review"]').on 'shown', () ->
        $('#sidenav').hide()
        $('#references').show()
    $('#issue_false_positive').change ->
        updateElementsVisibility()
    $('#issue_requires_verification').change ->
        updateElementsVisibility()
    $('#issue_fixed').change ->
        updateElementsVisibility()
    updateElementsVisibility()
    scrollToChild( '#response_body_container', '#response_body_container .proof' )
