=begin
    Copyright 2013 Tasos Laskos <tasos.laskos@gmail.com>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
=end

class Ability
    include CanCan::Ability

    def initialize( user )
        alias_action :errors, :report, :overview, to: :read
        alias_action :mark_read, to: :update
        alias_action :copy, to: :create

        user ||= User.new # guest user (not logged in)
        if user.has_role? :admin
            can :manage, :all
        else
            #
            # User access rules
            #

            # Let users see profiles of other users
            can :read, User

            #
            # Dispatcher access rules
            #

            # Can use the admin-defined ones to perform scans but can't
            # edit or create any.
            can :read, Dispatcher

            #
            # Profile access rules
            #

            # Can see/use global Profiles or Profiles which have been shared with them.
            can :read, Profile do |profile|
                profile.global? || profile.user_ids.include?( user.id )
            end

            # Can create personal Profiles -- controller assigns the User/Owner ID.
            can :create, Profile

            # Can manage Profiles they created.
            can :manage, Profile, owner_id: user.id

            cannot :make_default, Profile

            #
            # ScanGroup access rules
            #

            # Can see/use Scans which have been shared with them.
            can :read, ScanGroup do |sg|
                sg.user_ids.include?( user.id )
            end

            # Can manage ScanGroups they created.
            can :manage, ScanGroup, owner_id: user.id

            # Can create personal ScanGroups -- controller assigns the User/Owner ID.
            can :create, ScanGroup

            #
            # Scan access rules
            #

            # Can see Scans which have been shared with them or are members
            # of a shared group.
            can :read, Scan do |scan|
                scan.root_revision.user_ids.include?( user.id ) ||
                    scan.root_revision.scan_groups.where( 'user_ids in (?)', user.id )
            end

            # Can manage Scans they created.
            can :manage, Scan, owner_id: user.id

            # Can create personal Scans -- controller assigns the User/Owner ID.
            can :create, Scan

            #
            # Comment access rules
            #

            # Can read/create Comments if they can see the commentable model.
            can [:read, :create], Comment do |comment|
                can? :read, comment.commentable
            end

            #
            # Issue access rules
            #

            # Can see/update Issues is they can see the Scan.
            can [:read, :update], Issue do |issue|
                can? :read, issue.scan
            end

            #
            # Notification access rules
            #

            can :read, Notification do |notification|
                notification.model && can?( :read, notification.model )
            end

            # Can manage notifications they fired.
            can :manage, Notification, user_id: user.id
        end

        # Define abilities for the passed in user here. For example:
        #
        #   user ||= User.new # guest user (not logged in)
        #   if user.admin?
        #     can :manage, :all
        #   else
        #     can :read, :all
        #   end
        #
        # The first argument to `can` is the action you are giving the user permission to do.
        # If you pass :manage it will apply to every action. Other common actions here are
        # :read, :create, :update and :destroy.
        #
        # The second argument is the resource the user can perform the action on. If you pass
        # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
        #
        # The third argument is an optional hash of conditions to further filter the objects.
        # For example, here the user can only update published articles.
        #
        #   can :update, Article, :published => true
        #
        # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
    end
end
