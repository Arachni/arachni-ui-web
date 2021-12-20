FactoryBot.define do
    factory :issue do
        name 'Super important issue'
        description { Faker::Lorem.paragraph }
        url { Faker::Internet.url }
        vector_name 'input'
        vector_type {
            [Arachni::Element::LINK, Arachni::Element::FORM,
              Arachni::Element::COOKIE, Arachni::Element::HEADER].sample
        }

        cvssv2 '4.5'
        cwe '1'
        http_method { ['get', 'post', 'put'].sample }
        tags %w(these are a few tags)
        headers({
            request: {
                'User-Agent' => 'UA/v1'
            },
            response: {
                'Set-Cookie' => 'name=value'
            }
        })

        signature { Regexp.new( Faker::Lorem.sentence ).to_s }
        seed { Faker::Lorem.word }
        proof { Faker::Lorem.sentence }
        response_body { Faker::Lorem.paragraph }
        remarks({ the_dude: ['Hey!'] })

        audit_options {{
            params: { Faker::Lorem.word => Faker::Lorem.word }
        }}

        references {{ Faker::Lorem.word => Faker::Internet.url }}
        remedy_code { Faker::Lorem.paragraph }
        remedy_guidance { Faker::Lorem.paragraph }
        severity { Issue::ORDERED_SEVERITIES.sample }
        digest { Digest::SHA2.hexdigest rand( 999999 ).to_s }
    end

    factory :issue_requiring_verification, parent: :issue do
        requires_verification true
    end

    factory :issue_fixed, parent: :issue do
        fixed true
    end

    factory :issue_verified, parent: :issue_requiring_verification do
        verified true
    end

    factory :issue_false_positive, parent: :issue do
        false_positive true
    end

    factory :issue_with_verification_steps, parent: :issue_requiring_verification do
        verification_steps { Faker::Lorem.paragraph }
    end

    factory :issue_with_remediation_steps, parent: :issue do
        remediation_steps { Faker::Lorem.paragraph }
    end
end
