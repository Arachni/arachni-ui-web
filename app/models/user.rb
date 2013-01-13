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

class User < ActiveRecord::Base
    has_and_belongs_to_many :scans
    has_many :comments

    rolify
    # Include default devise modules. Others available are:
    # :token_authenticatable, :confirmable,
    # :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
            :rememberable, :trackable, :validatable

    # Setup accessible (or protected) attributes for your model
    attr_accessible :name, :email, :password, :password_confirmation,
                    :remember_me, :role_ids

    def admin?
        has_role? :admin
    end

    def to_s
        name
    end

    def self.recent( limit = 5 )
        find( :all, order: "id desc", limit: limit )
    end

    def own_scans
        scans.where( owner_id: id )
    end

    def ability
        @ability ||= Ability.new( self )
    end
    delegate :can?, :cannot?, :to => :ability
end
