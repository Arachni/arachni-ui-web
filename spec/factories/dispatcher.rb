FactoryGirl.define do

    factory :dispatcher do
        ignore do
            server_options {}
        end

        address { 'localhost' }
        port { ProcessHelper.generate_port }

        # Fire up a real Dispatcher to pass validations.
        before( :create ) do |d, evaluator|
            next if !d.address || !d.port

            opts = (evaluator.server_options || {}).
                merge( 'rpc_address' =>  d.address, 'rpc_port' => d.port )

            begin
                ProcessHelper.start_dispatcher( opts )
            rescue => e
                ap e
            end
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
            ProcessHelper.kill_dispatcher d
        end
    end

end
