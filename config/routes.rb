=begin
    Copyright 2010-2012 Tasos Laskos <tasos.laskos@gmail.com>

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

ArachniWebui::Application.routes.draw do
    resources :notifications, only: [:mark_all_read, :destroy] do
        put :mark_read, on: :collection
    end

    resources :dispatchers

    resources :scans, except: [:edit] do
        resources :comments
        resources :issues, only: [ :index, :show, :update ] do
            resources :comments
        end

        get :new_revision, on: :member

        post :repeat,   on: :member

        put :share,    on: :member
        put :pause,    on: :member
        put :resume,   on: :member
        put :abort,    on: :member
        get :report,   on: :member
        get :comments, on: :member
        get :errors,   on: :member
        get :count,    on: :collection
    end

    resources :profiles do
        put :make_default, on: :member
    end

    get 'profiles/new(/:id)' => 'profiles#new', as: :new_profile

    get '/navigation', :to => 'home#navigation'

    authenticated :user do
        root to: 'home#index'
    end
    root to: 'home#index'

    devise_for :users, :skip => [:registrations], path_prefix: 'd'
    as :user do
        get 'users/edit' => 'devise/registrations#edit', as: 'edit_user_registration'
        put 'users' => 'devise/registrations#update', as: 'user_registration'
    end
    resources :users
end
