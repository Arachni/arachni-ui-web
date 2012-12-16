# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

puts 'SETTING UP DEFAULT USERS'
user = User.create! name: 'First User', email: 'user@example.com',
                    password: 'please', password_confirmation: 'please'
user.add_role :admin
puts 'New user created: ' << user.name

user2 = User.create! name: 'Second User', email: 'user2@example.com',
                     password: 'please', password_confirmation: 'please'
puts 'New user created: ' << user2.name

puts 'SETTING UP DEFAULT PROFILE'
p = Profile.create! name: 'Default', audit_links: true, audit_forms: true,
                audit_cookies: true, http_req_limit: 20, modules: :all,
                plugins: :default, description: 'Relatively sensible configuration settings.'
p.make_default
puts 'Default profile created: ' << p.name

p = Profile.create! name: 'XSS', audit_links: true, audit_forms: true,
                    audit_cookies: true, http_req_limit: 20,
                    modules: %w(xss xss_path xss_tag xss_script_tag xss_event),
                    plugins: :default, description: 'Scans for XSS vulnerabilities.'
puts 'XSS profile created: ' << p.name

p = Profile.create! name: 'XSS - forms', audit_forms: true,
                    http_req_limit: 20,
                    modules: %w(xss xss_path xss_tag xss_script_tag xss_event),
                    plugins: :default, description: 'Scans for XSS vulnerabilities.'
puts 'XSS profile created: ' << p.name
