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
        alias_action :errors, :comments, :partial, :index_tables, to: :read

        user ||= User.new # guest user (not logged in)
        if user.has_role? :admin
            can :manage, :all
        else
            can :read, [Profile, Dispatcher]

            can :read, Scan do |scan|
                scan.user_ids.include? user.id
            end

            can :manage, Scan, owner_id: user.id

            can :create, Scan

            can [:read, :create], Comment do |comment|
                can? :read, comment.commentable
            end
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
