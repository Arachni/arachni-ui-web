# Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>
#
# This file is part of the Arachni WebUI project and is subject to
# redistribution and commercial restrictions. Please see the Arachni WebUI
# web site for more information on licensing and terms of use.

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

window.commentCount = () ->
    $('#comments-list .comment').size()

window.newCommentsCount = 0

window.resetCommentCounters = () ->
    window.newCommentsCount = 0
    window.initialCommentCount = window.commentCount()

    $('.total-comments-counter').html( window.initialCommentCount )
    if window.initialCommentCount > 0
        $('.total-comments-counter').show()
    $('.new-comments-counter').hide()

window.hookFormOnSubmit = () ->
    $('#new_comment').on 'submit', () ->
        $('#posting-comment-spinner').show()

window.setupComments = () ->
    $('.toggle-comments').click ->
        window.resetCommentCounters()
        $('#comment_text').focus()

    window.hookFormOnSubmit()

    $('#updater').on 'refresh', () ->
        window.commentsWereOpen    = $('#comments').hasClass( 'in' )

    $('#updater').on 'refreshed', () ->
        window.newCommentsCount = window.commentCount() - window.initialCommentCount
        if window.newCommentsCount > 0 && !window.commentsWereOpen
            $('.new-comments-counter' ).html( '+' + window.newCommentsCount )
            $('.new-comments-counter').show()
        else if( window.initialCommentCount + window.newCommentsCount > 0 )
            $('.total-comments-counter' ).html( window.initialCommentCount + window.newCommentsCount )
            $('.total-comments-counter').show()

jQuery ->
    window.resetCommentCounters();
    window.setupComments()
