=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

class User < ActiveRecord::Base
    has_and_belongs_to_many :scans
    has_and_belongs_to_many :profiles
    has_and_belongs_to_many :dispatchers
    has_many :comments
    has_many :notifications, dependent: :destroy
    has_and_belongs_to_many :scan_groups

    rolify
    # Include default devise modules. Others available are:
    # :token_authenticatable, :confirmable,
    # :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
           :rememberable, :trackable, :validatable

    def scan_limit_exceeded?
        !admin? &&
            Settings.scan_per_user_limit && own_scans.active.size >= Settings.scan_per_user_limit
    end

    def available_profiles
        Profile.where( id: profiles.pluck( :id ) + Profile.global.pluck( :id ) )
    end

    def available_dispatchers
        Dispatcher.where( id: dispatchers.pluck( :id ) + Dispatcher.global.pluck( :id ) )
    end

    def admin?
        has_role? :admin
    end

    def to_s
        name
    end

    def name
        n = super
        return if !n

        n.force_encoding('utf-8')
    end

    def notifications
        super.where( 'actor_id IS NULL OR actor_id != ?', id ).order( 'id desc' )
    end

    def activities
        ids = Notification.pluck( :identifier ).uniq.map do |id|
            Notification.where( identifier: id ).first.id
        end
        Notification.where( 'id in (?)', ids ).where( 'actor_id = ?', id ).order( 'id desc' )
    end

    def self.recent( limit = 5 )
        limit( limit ).order( "id desc" )
    end

    def own_scans
        scans.where( owner_id: id ).order( 'id desc' )
    end

    def own_scan_groups
        scan_groups.where( owner_id: id ).order( 'id desc' )
    end

    def shared_scan_groups
        scan_groups.where( 'owner_id != ?', id ).order( 'id desc' )
    end

    def others_scan_groups
        return none if !admin?

        ScanGroup.where( 'owner_id != ?', id ).
            where( 'id not in (?)', scan_group_ids ).
            order( 'id desc' )
    end

    def own_dispatchers
        dispatchers.where( owner_id: id ).order( 'id desc' )
    end

    def shared_dispatchers
        dispatchers.where( 'owner_id != ?', id ).order( 'id desc' )
    end

    def others_dispatchers
        return none if !admin?

        Dispatcher.where( 'owner_id != ?', id ).
            where( 'id not in (?)', dispatcher_ids ).
            order( 'id desc' )
    end

    def ability
        @ability ||= Ability.new( self )
    end
    delegate :can?, :cannot?, to: :ability
end
