require 'spec_helper'

describe Dispatcher do

    after :each do
        # Factories start actual Dispatchers so don't let them accumulate.
        dispatcher_killall
    end

    describe :factory do
        describe :dispatcher do
            it 'creates a valid model' do
                FactoryBot.create(:dispatcher).should be_valid
            end
        end

        describe :global_dispatcher do
            it 'creates a valid model' do
                FactoryBot.create(:global_dispatcher).should be_valid
            end
            it 'creates a Global Dispatcher model' do
                FactoryBot.create(:global_dispatcher).global.should be_true
            end
            it 'creates an alive Dispatcher model' do
                FactoryBot.create(:global_dispatcher).alive.should be_true
            end
            it 'creates an alive Dispatcher server' do
                FactoryBot.create(:global_dispatcher).client.alive?.should be_true
            end
        end

        describe :alive_dispatcher do
            it 'creates a valid model' do
                FactoryBot.create(:alive_dispatcher).should be_valid
            end
            it 'creates an alive Dispatcher model' do
                FactoryBot.create(:alive_dispatcher).alive.should be_true
            end
            it 'creates an alive Dispatcher server' do
                dispatcher = FactoryBot.create(:alive_dispatcher).client
                dispatcher.alive?.should be_true
            end
        end

        describe :dead_dispatcher do
            it 'saves a model in the DB' do
                FactoryBot.create(:dead_dispatcher).id.should_not be_nil
            end
            it 'creates a invalid model' do
                FactoryBot.create(:dead_dispatcher).should be_invalid
            end
            it 'creates a dead Dispatcher model' do
                FactoryBot.create(:dead_dispatcher).alive.should be_false
            end
            it 'creates a dead Dispatcher server' do
                alive = true
                begin
                    FactoryBot.create(:dead_dispatcher).client.alive?
                rescue Arachni::RPC::Exceptions::ConnectionError
                    alive = false
                end
                alive.should be_false
            end
        end
    end

    describe :validation do
        it 'is valid with a server listening at address:port' do
            FactoryBot.create(:dispatcher).should be_valid
        end

        it 'is invalid without :address' do
            FactoryBot.build( :dispatcher, address: nil ).should be_invalid
        end

        it 'is invalid without :port' do
            FactoryBot.build( :dispatcher, port: nil ).should be_invalid
        end

        it 'is invalid with a non-numeric :port' do
            FactoryBot.build( :dispatcher, port: Faker::Lorem.word ).should be_invalid
        end

        it 'is invalid without a server listening at address:port' do
            FactoryBot.build( :dispatcher,
                               address: Faker::Internet.ip_v4_address,
                               port: rand( 999 ) + 3000 )
                should be_invalid
        end

        it 'is invalid with duplicate address:port' do
            attrs = FactoryBot.attributes_for(:dispatcher)

            FactoryBot.create( :dispatcher, attrs ).should be_valid
            FactoryBot.build( :dispatcher, attrs ).should be_invalid
        end
    end

    describe :scope do
        describe '.alive' do
            it 'returns alive Dispatchers' do
                # These will remain alive.
                alive = []
                3.times { alive << FactoryBot.create( :alive_dispatcher ) }

                # This is the dead one.
                FactoryBot.create( :dead_dispatcher )

                Dispatcher.alive.should == alive
            end
        end

        describe '.unreachable' do
            it 'returns unreachable Dispatchers' do
                # These will remain alive.
                alive = []
                3.times { alive << FactoryBot.create( :alive_dispatcher ) }

                # This is the dead one.
                d = FactoryBot.create( :dead_dispatcher )

                Dispatcher.unreachable.should == [d]
            end
        end

        describe '.global' do
            it 'returns globally accessible Dispatchers' do
                # These will remain alive.
                alive = []
                3.times { alive << FactoryBot.create( :alive_dispatcher ) }

                FactoryBot.create( :dead_dispatcher )

                d = FactoryBot.create( :global_dispatcher )

                Dispatcher.global.should == [d]
            end
        end
    end

    describe '.describe_notification' do
        it 'returns a description for the given notification action'
    end

    describe '.preferred' do
        it 'returns the Dispatcher with the lowest workload score' do
            FactoryBot.create( :dispatcher, score: 3 )
            FactoryBot.create( :dispatcher, score: 2 )
            d = FactoryBot.create( :dispatcher, score: 1 )

            Dispatcher.preferred.should == d
        end
    end

    describe '.default' do
        it 'returns the default Dispatcher' do
            3.times { FactoryBot.create( :dispatcher ) }

            d = FactoryBot.create( :dispatcher, default: true )
            Dispatcher.default.should == d
        end
    end

    describe '.unmake_default' do
        it 'unsets the Default Dispatcher' do
            d = FactoryBot.create( :dispatcher, default: true )
            d.default?.should be_true
            Dispatcher.unmake_default
            d.reload.default?.should be_false
        end
    end

    describe '.find_by_url' do
        it 'returns a Dispatcher by its address:port' do
            3.times { FactoryBot.create( :dispatcher ) }

            d = FactoryBot.create( :dispatcher, default: true )
            Dispatcher.find_by_url( d.url ) == d
        end
    end

    describe '.grid_members' do
        it 'returns all Dispatchers which are members of a Grid' do
            3.times { FactoryBot.create( :dispatcher ) }

            d = FactoryBot.create( :dispatcher )

            d = FactoryBot.create( :dispatcher, default: true )
            Dispatcher.find_by_url( d.url ) == [d]
        end
    end

    describe '.non_grid_members' do
        it 'returns all solo Dispatchers'
    end

    describe '.has_grid?' do
        context 'when there is at least one Grid' do
            it 'returns true'
        end

        context 'when there are no Grids' do
            it 'returns false' do
                Dispatcher.has_grid?.should be_false
            end
        end
    end

    describe '.recent' do
        it 'returns the 5 most recently added Dispatchers' do
            dispatchers = []
            6.times { dispatchers << FactoryBot.create( :dispatcher ) }

            Dispatcher.recent.should == dispatchers.reverse[0...5]
        end

        context 'when passed an argument' do
            it 'returns the specified number of most recently added Dispatchers' do
                dispatchers = []
                6.times { dispatchers << FactoryBot.create( :dispatcher ) }

                Dispatcher.recent( 3 ).should == dispatchers.reverse[0...3]
            end
        end
    end

    describe '#to_label' do
        it 'returns a text label' do
            FactoryBot.create( :dispatcher ).to_label.should be_kind_of(String)
        end

        context 'when the Dispatcher has running scans' do
            it 'should include the amount'
        end

        context 'when the Dispatcher is a Grid member' do
            it 'should include the Pipe-ID'
        end
    end

    describe '#to_s' do
        it 'returns the URL of the Dispatcher' do
            d = FactoryBot.create( :dispatcher )
            d.to_s.should == d.url
        end

        context 'when the Dispatcher has a #name' do
            it 'should be included' do
                d = FactoryBot.create( :dispatcher,
                                        statistics: { 'node' => {'nickname' => 'test'} } )

                d.name.should == 'test'
            end
        end
    end

    describe '#grid_member?' do
        context 'when the Dispatcher is a member of a Grid' do
            it 'returns true' do
                d = FactoryBot.create( :alive_dispatcher,
                                        statistics: {
                                            'node' => { 'pipe_id' => rand(999).to_s }
                                        }
                )

                FactoryBot.create( :alive_dispatcher,
                                        statistics: {
                                            'neighbours' => [d.url],
                                            'node' => { 'pipe_id' => rand(999).to_s }
                                        }
                )

                d.grid_member?.should be_true
            end
        end
        context 'when the Dispatcher is not a member of a Grid' do
            it 'returns false' do
                FactoryBot.create(:alive_dispatcher).grid_member?.should be_false
            end
        end
    end

    describe '#make_default' do
        it 'sets self as the default Dispatcher' do
            d = FactoryBot.create( :dispatcher )
            d.default?.should be_false
            d.make_default
            d.reload.default?.should be_true
        end
        it 'unsets the previous default Dispatcher' do
            d = FactoryBot.create( :dispatcher )
            d.make_default
            d.default?.should be_true

            c = FactoryBot.create( :dispatcher )
            c.make_default
            c.default?.should be_true

            d.reload.default?.should be_false
        end
    end

    describe '#subscribers' do
        it 'returns users which should be notified upon changes' do
            users = (0..2).map { FactoryBot.create( :user ) }
            FactoryBot.create( :dispatcher, users: users ).subscribers.should == users
        end

        it 'should automatically include the owner' do
            users = (0..2).map { FactoryBot.create( :user ) }
            owner = FactoryBot.create( :user )

            FactoryBot.create( :dispatcher, owner: owner, users: users ).
                subscribers.should == users | [owner]
        end
    end

    describe '#statistics' do
        it 'returns statistics and information directly from the Dispatcher server'

        context 'when there are no statistics' do
            it "returns a Hash with a 'node' key (with an empty Hash as value)" do
                FactoryBot.create( :dispatcher ).statistics.should == { 'node' => {} }
            end
        end
    end

    describe '#consumed_pids' do
        it 'returns an Array of PIDs used up by the Dispatcher for Instances'
    end

    describe '#name' do
        it 'returns the Dispatcher name-- as configured on the server-side'
    end

    describe '#pipe_id' do
        it 'returns the ID of bandwidth pipe -- as configured on the server-side'
    end

    describe '#weight' do
        it 'returns the value of the weight option -- as configured on the server-side'
    end

    describe '#jobs' do
        it 'returns an Array of Hashes containing info about Instances which are still alive'
    end

    describe '#finished_jobs' do
        it 'returns an Array of Hashes containing info about Instances which have been shutdown'
    end

    describe '#node_info' do
        it 'returns a Hash containing info about the Dispatcher node'
    end

    describe '#neighbours' do
        it 'returns array of neighbour Dispatchers'
    end

    describe '#url' do
        it 'returns address:port' do
            d = FactoryBot.create( :dispatcher )
            d.url.should == "#{d.address}:#{d.port}"
            d.url.should == d.client.url
        end
    end

    describe '#client' do
        it 'returns an RPC client' do
            FactoryBot.create( :dispatcher ).client.should be_kind_of( Arachni::RPC::Client::Dispatcher )
        end
    end

    describe '#refresh' do
        it 'refreshes liveness'
        it 'refreshes statistics'
        it 'refreshes workload score'
        it 'refreshes neighbours'
    end

    describe '#family' do
        it 'returns nested family list from the child (self) to the oldest ancestor' do
            d = FactoryBot.build(:dispatcher)
            d.family.should == [d]
        end
    end

end
