# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

puts 'SETTING UP EMPTY SETTINGS'
Setting.create! scan_allowed_types: Setting::SCAN_TYPES,
                profile_allowed_checks:  FrameworkHelper.checks.keys,
                profile_allowed_plugins: FrameworkHelper.plugins.keys

puts 'SETTING UP DEFAULT USERS'
user = User.create! name:                  'Administrator',
                    email:                 'admin@admin.admin',
                    password:              'administrator',
                    password_confirmation: 'administrator'
user.add_role :admin
puts 'Admin user created: ' << user.name

admin_id = user.id

user = User.create! name:                  'Regular User',
                    email:                 'user@user.user',
                    password:              'regular_user',
                    password_confirmation: 'regular_user'
puts 'Regular user created: ' << user.name

# ignore  = Set.new(%w(http_cookie_jar_filepath http_proxy http_cookies).map(&:to_sym))
# columns = []
#
# Arachni::Options.to_rpc_data.each do |name, _|
#     name = name.to_sym
#
#     if Arachni::Options.group_classes.include?( name )
#         Arachni::Options.send(name).attributes.each do |k|
#             columns << "#{name}_#{k}".to_sym
#         end
#     else
#         columns << name
#     end
# end
#
# ap columns.reject { |column| ignore.include? column }
# exit

arachni_defaults = {}
profile_columns  = Profile.column_names

Arachni::Options.to_rpc_data.each do |name, value|
    name = name.to_sym
    next if value.nil?

    if Arachni::Options.group_classes.include?( name )
        value.each do |k, v|
            next if v.nil?

            key = "#{name}_#{k}".to_sym
            if !profile_columns.include?( key.to_s )
                $stderr.puts "[Profile defaults] Ignoring: #{key}"
                next
            end

            arachni_defaults[key] = v
        end
    else
        if !profile_columns.include?( name.to_s )
            $stderr.puts "[Profile defaults] Ignoring: #{name}"
            next
        end
        arachni_defaults[name] = value
    end
end

arachni_defaults.merge!(
    name:          'Default',
    description:   'Sensible, default settings.',
    global:        true,
    owner_id:      admin_id,
    user_ids:      [admin_id],
    audit_links:   true,
    audit_forms:   true,
    audit_cookies: true,
    audit_nested_cookies: true,
    audit_jsons:   true,
    audit_xmls:    true,
    audit_ui_forms:  true,
    audit_ui_inputs: true,
    plugins:       :default,
    input_values:  Arachni::Options.input.default_values
)

ap arachni_defaults

# exit

puts

puts 'SETTING UP DEFAULT PROFILES'
p = Profile.create! arachni_defaults.merge(
                        name:          'Default',
                        description:   'Sensible, default settings.',
                        checks:       :all
                    )
p.make_default
puts 'Default profile created: ' << p.name

p = Profile.create! arachni_defaults.merge(
                        name: 'Cross-Site Scripting (XSS)',
                        description: 'Scans for Cross-Site Scripting (XSS) vulnerabilities.',
                        checks: %w(xss xss_path xss_tag xss_script_context xss_event
                                    xss_dom xss_dom_inputs xss_dom_script_context)
                    )
puts 'XSS profile created: ' << p.name

p = Profile.create! arachni_defaults.merge(
                        name: 'SQL injection',
                        description: 'Scans for SQL injection vulnerabilities.',
                        checks: %w(sql_injection sql_injection_differential sql_injection_timing)
                    )
puts 'SQLi profile created: ' << p.name
