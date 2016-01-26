=begin
    Copyright 2013-2016 Tasos Laskos <tasos.laskos@arachni-scanner.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

class Role < ActiveRecord::Base
    has_and_belongs_to_many :users, join_table: :users_roles
    belongs_to :resource, polymorphic: true

    scopify
end
