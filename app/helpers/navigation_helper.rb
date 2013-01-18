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

module NavigationHelper

    def title( title )
        content_for :title, title.to_s
    end

    def breadcrumbs
        @navigation ||= []
    end

    def title_breadcrumbs
        breadcrumbs.map { |b| b[:title] }.reverse.join( ' - ' )
    end

    def breadcrumb_add( title, url )
        breadcrumbs << { title: title, url: url }
    end

    def render_breadcrumbs
        render partial: 'layouts/breadcrumbs', locals: { breadcrumbs: breadcrumbs }
    end

    def active_controller?( controller )
        params[:controller] == controller
    end

    def mark_if_active( controller )
        'class="active"'.html_safe if active_controller?( controller )
    end

    def show_sidebar?
        has_subnav? || !sidebar.to_s.empty?
    end

    def subnav( sections, opts = {} )
        object_for( :subnav, [sections, opts] )
    end

    def sidebar
        @sidebar ||= ''
    end

    def add_to_sidebar( &block )
        s = capture( &block )
        sidebar << s
        s
    end

    def has_subnav?
        object_for? :subnav
    end

    def render_subnav( sections = nil )
        args = pop_object_for( :subnav )

        sections ||= args.first
        opts       = args.last

        if sections
            render partial: 'layouts/subnav',
                   locals: { sections: sections, opts: opts }
        end
    end
end
