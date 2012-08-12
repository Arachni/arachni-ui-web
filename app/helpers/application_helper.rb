module ApplicationHelper
    def title( title )
        content_for :title, title.to_s
    end
end
