require 'machinist/active_record'

# Add your blueprints here.
#
# e.g.
#   Post.blueprint do
#     title { "Post #{sn}" }
#     body  { "Lorem ipsum..." }
#   end

User.blueprint do
  # Attributes here
end

Profile.blueprint do
  # Attributes here
end

Scan.blueprint do
  # Attributes here
end

Issue.blueprint do
  # Attributes here
end

Scan::Comment.blueprint do
  # Attributes here
end

Dispatcher.blueprint do
  # Attributes here
end
