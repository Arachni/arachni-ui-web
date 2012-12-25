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
    resources :dispatchers

    resources :comments

    resources :scans do
        put :pause,    on: :member
        put :resume,   on: :member
        put :abort,    on: :member
        get :report,   on: :member
        get :comments, on: :member
        get :count,    on: :collection
    end

    resources :profiles do
        put :make_default, on: :member
    end

    match 'profiles/new(/:id)' => 'profiles#new', as: :new_profile

    authenticated :user do
        root to: 'home#index'
    end
    root to: 'home#index'

    devise_for :users, :skip => [:registrations]
    as :user do
        get 'users/edit' => 'devise/registrations#edit', as: 'edit_user_registration'
        put 'users' => 'devise/registrations#update', as: 'user_registration'
    end
    resources :users, only: [:show, :index]
end
