FactoryBot.define do

    factory :dispatcher do
        ignore do
            server_options {}
        end

        address { 'localhost' }
        port { Arachni::Utilities.available_port }

        # Fire up a real Dispatcher to pass validations.
        before( :create ) do |d, evaluator|
            next if !d.address || !d.port
            dispatcher_spawn (evaluator.server_options || {}).
                                 merge( address: d.address, port: d.port )
        end

    end

    factory :alive_dispatcher, parent: :dispatcher do
        alive true
    end

    factory :global_dispatcher, parent: :alive_dispatcher do
        global true
    end

    factory :dead_dispatcher, parent: :dispatcher do
        alive false

        after :create do |d|
            dispatcher_kill d.url
        end
    end

end
