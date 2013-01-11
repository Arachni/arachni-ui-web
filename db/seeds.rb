# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

puts 'SETTING UP DEFAULT USERS'
user = User.create! name:                  'Administrator',
                    email:                 'admin@admin.com',
                    password:              'administrator',
                    password_confirmation: 'administrator'
user.add_role :admin
puts 'Admin user created: ' << user.name

arachni_defaults = {}

ignore = %w(max_slaves)
profile_columns = Profile.column_names
Arachni::Options.to_h.each do |k, v|
    next if v.nil? || !profile_columns.include?( k ) || ignore.include?( k )

    arachni_defaults[k.to_sym] = v
end

arachni_defaults.merge!(
    name:          'Default',
    description:   'Sensible, default settings.',
    audit_links:   true,
    audit_forms:   true,
    audit_cookies: true,
    plugins:       :default
)

puts 'SETTING UP DEFAULT PROFILE'
p = Profile.create! arachni_defaults.merge(
                        name:          'Default',
                        description:   'Sensible, default settings.',
                        modules:       :all
                    )
p.make_default
puts 'Default profile created: ' << p.name

p = Profile.create! arachni_defaults.merge(
                        name: 'Cross-Site Scripting (XSS)',
                        description: 'Scans for Cross-Site Scripting (XSS) vulnerabilities.',
                        modules: %w(xss xss_path xss_tag xss_script_tag xss_event)
                    )
puts 'XSS profile created: ' << p.name

p = Profile.create! arachni_defaults.merge(
                        name: 'SQL injection',
                        description: 'Scans for SQL injection vulnerabilities.',
                        modules: %w(sqli sqli_blind_rdiff sqli_blind_timing)
                    )
puts 'SQLi profile created: ' << p.name
