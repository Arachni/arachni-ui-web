# Copyright 2013-2014 Tasos Laskos <tasos.laskos@arachni-scanner.com>
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
