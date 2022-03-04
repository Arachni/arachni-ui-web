=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
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

    def show_affixed_sidebar?
        has_subnav? || !affixed_sidebar.to_s.empty?
    end

    def show_sidebar?
        !sidebar.to_s.empty?
    end

    def subnav( sections, opts = {} )
        object_for( :subnav, [sections, opts] )
    end

    def sidebar
        @sidebar ||= ''
    end

    def affixed_sidebar
        @affixed_sidebar ||= ''
    end

    def add_to_sidebar( &block )
        s = capture( &block )
        sidebar << s
        s
    end

    def add_to_affixed_sidebar( &block )
        s = capture( &block )
        affixed_sidebar << s
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
