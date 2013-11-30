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

if !localStorage['issue_visibility']
    localStorage['issue_visibility'] = JSON.stringify({})

renderResponse = ( container, html ) ->

    if ( !window.warned )
        confirm_render = window.confirm( "Rendering the response will also execute" +
            " any JavaScript code that might be included in the page," +
            " are you sure you want to continue?" )

        window.warned = confirm_render
        return if(!confirm_render)

    $('#rendered-response-container').modal('show');
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

window.showAllIssues = () ->
    visibilities = JSON.parse( localStorage['issue_visibility'] )

    for issue in $('.issue-group-container')
        $(issue).show('fast')
        visibilities[$(issue).attr('id')] = true

    localStorage['issue_visibility'] = JSON.stringify( visibilities )

window.hideAllIssues = () ->
    visibilities = JSON.parse( localStorage['issue_visibility'] )

    for issue in $('.issue-group-container')
        visibilities[$(issue).attr('id')] = false
        $(issue).hide('fast')

    localStorage['issue_visibility'] = JSON.stringify( visibilities )

window.restoreIssueVisibility = () ->
    visibilities = JSON.parse( localStorage['issue_visibility'] )

    for issue in $('.issue-group-container')
        issue = $(issue)
        switch visibilities[issue.attr('id')]
            when true then issue.show()
            when false then issue.hide()
            else

window.resetIssues = () ->
    visibilities = JSON.parse( localStorage['issue_visibility'] )

    for issue in $('.issue-group-container')
        issue = $(issue)
        visibilities[issue.attr('id')] = ['high', 'medium'].contains(issue.data('severity'))

        if visibilities[issue.attr('id')]
            issue.show('fast')
        else
            issue.hide('fast')

    localStorage['issue_visibility'] = JSON.stringify( visibilities )

window.toggleIssuesBySeverity = ( severity ) ->
    visibilities = JSON.parse( localStorage['issue_visibility'] )

    for issue in $('.severity-' + severity)
        visibilities[$(issue).attr('id')] = !$(issue).is(":visible")
        $(issue).toggle('fast')

    localStorage['issue_visibility'] = JSON.stringify( visibilities )

window.toggleIssue = ( selector ) ->
    visibilities = JSON.parse( localStorage['issue_visibility'] )
    issue        = $(selector)

    visibilities[issue.attr('id')] = !issue.is(":visible")
    issue.toggle('fast')

    localStorage['issue_visibility'] = JSON.stringify( visibilities )

window.scrollToIssue = ( id ) ->
    issue = $(id)
    toggleIssue(id) if !issue.is(':visible')
    $(window).scrollTop( issue.offset().top - $('html, body').offset().top - $('header').height() - 47)

jQuery ->
    $('#render-response-button' ).click ->
        renderResponse( $('#rendered-response-container .modal-body'), $(this).data( 'html' ) )
    $('#issue-tabs a[href$="technical-details"]').on 'shown', () ->
        $('#sidenav').show()
    $('#issue-tabs a[href$="discussion"]').on 'shown', () ->
        $('#sidenav').hide()
    $('#issue-tabs a[href$="verification"]').on 'shown', () ->
        $('#sidenav').hide()
    $('#issue-tabs a[href$="review"]').on 'shown', () ->
        $('#sidenav').hide()
    $('#issue_false_positive').change ->
        updateElementsVisibility()
    $('#issue_requires_verification').change ->
        updateElementsVisibility()
    $('#issue_fixed').change ->
        updateElementsVisibility()
    updateElementsVisibility()
    scrollToChild( '#response_body_container', '#response_body_container .proof' )
    window.restoreIssueVisibility()
