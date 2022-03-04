=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

ArachniWebui::Application.routes.draw do
    resources :settings

    resources :notifications, only: [:mark_all_read, :destroy] do
        patch :mark_read, on: :collection
    end

    resources :dispatchers do
        patch :make_default, on: :member
        patch :share,        on: :member
    end

    scope 'scans' do
        resources :scan_groups, path: 'groups',
                  only: [ :new, :edit, :create, :update, :destroy ]
    end

    resources :scans do
        resources :comments
        resources :issues, only: [ :index, :show, :update ] do
            resources :comments
        end

        post :repeat,   on: :member

        patch :update_memberships,    on: :member
        patch :suspend,  on: :member
        patch :restore,  on: :member
        patch :share,    on: :member
        patch :pause,    on: :member
        patch :resume,   on: :member
        patch :abort,    on: :member

        post  :import,   on: :collection

        patch :suspend,  on: :collection, to: :suspend_all
        patch :pause,    on: :collection, to: :pause_all
        patch :resume,   on: :collection, to: :resume_all
        patch :abort,    on: :collection, to: :abort_all

        get :new_revision, on: :member
        get :report,   on: :member
        get :comments, on: :member
        get :errors,   on: :member
        get :count,    on: :collection
        get :schedule, on: :collection
    end

    resources :profiles do
        post  :import,       on: :collection
        patch :make_default, on: :member
        patch :share,        on: :member
        get   :copy,         on: :member
    end

    get '/navigation', :to => 'home#navigation'
    get '/welcome',    :to => 'home#welcome'

    root to: 'home#index'

    devise_for :users, :skip => [:registrations], path_prefix: 'd'
    as :user do
        get 'users/edit' => 'devise/registrations#edit', as: 'edit_user_registration'
        patch 'users' => 'devise/registrations#update', as: 'user_registration'
    end
    resources :users
end
