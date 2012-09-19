require 'spec_helper'

describe Profile do

    before :all do
        @new_profile = proc { Profile.new( name: 'stuff', description: 'Desc' ) }
    end

    describe '#redundant=' do
        before { @expected = { "match-this" => "3", "match_this_too" => "4" } }
        context 'when the parameter is a' do
            context String do
                it 'should be parsed and converted to a Hash before saving' do
                    p = @new_profile.call
                    p.redundant = "match-this:3\nmatch_this_too:4"
                    p.redundant.should == @expected

                    p = @new_profile.call
                    p.redundant = "match-this:3\n\rmatch_this_too:4"
                    p.redundant.should == @expected
                end
            end
            context Hash do
                it 'should be saved' do
                    p = @new_profile.call
                    p.redundant = @expected
                    p.redundant.should == @expected
                end
            end
        end
    end

    describe '#exclude=' do
        before { @expected = [ "exclude this", "this-too!" ] }
        context 'when the parameter is a' do
            context String do
                it 'should be parsed and converted to an Array before saving' do
                    p = @new_profile.call
                    p.exclude = "exclude this\nthis-too!"
                    p.exclude.should == @expected

                    p = @new_profile.call
                    p.exclude = "exclude this\n\rthis-too!"
                    p.exclude.should == @expected
                end
            end
            context Array do
                it 'should be saved' do
                    p = @new_profile.call
                    p.exclude = @expected
                    p.exclude.should == @expected
                end
            end
        end
    end

    describe '#include=' do
        before { @expected = [ "include this", "this-too!" ] }
        context 'when the parameter is a' do
            context String do
                it 'should be parsed and converted to an Array before saving' do
                    p = @new_profile.call
                    p.include = "include this\nthis-too!"
                    p.include.should == @expected

                    p = @new_profile.call
                    p.include = "include this\n\rthis-too!"
                    p.include.should == @expected
                end
            end
            context Array do
                it 'should be saved' do
                    p = @new_profile.call
                    p.include = @expected
                    p.include.should == @expected
                end
            end
        end
    end

    describe '#restrict_paths=' do
        before { @expected = [ "include this", "this-too!" ] }
        context 'when the parameter is a' do
            context String do
                it 'should be parsed and converted to an Array before saving' do
                    p = @new_profile.call
                    p.restrict_paths = "include this\nthis-too!"
                    p.restrict_paths.should == @expected

                    p = @new_profile.call
                    p.restrict_paths = "include this\n\rthis-too!"
                    p.restrict_paths.should == @expected
                end
            end
            context Array do
                it 'should be saved' do
                    p = @new_profile.call
                    p.restrict_paths = @expected
                    p.restrict_paths.should == @expected
                end
            end
        end
    end

    describe '#extend_paths=' do
        before { @expected = [ "include this", "this-too!" ] }
        context 'when the parameter is a' do
            context String do
                it 'should be parsed and converted to an Array before saving' do
                    p = @new_profile.call
                    p.extend_paths = "include this\nthis-too!"
                    p.extend_paths.should == @expected

                    p = @new_profile.call
                    p.extend_paths = "include this\n\rthis-too!"
                    p.extend_paths.should == @expected
                end
            end
            context Array do
                it 'should be saved' do
                    p = @new_profile.call
                    p.extend_paths = @expected
                    p.extend_paths.should == @expected
                end
            end
        end
    end

    describe '#exclude_vectors=' do
        before { @expected = [ "include this", "this-too!" ] }
        context 'when the parameter is a' do
            context String do
                it 'should be parsed and converted to an Array before saving' do
                    p = @new_profile.call
                    p.exclude_vectors = "include this\nthis-too!"
                    p.exclude_vectors.should == @expected

                    p = @new_profile.call
                    p.exclude_vectors = "include this\n\rthis-too!"
                    p.exclude_vectors.should == @expected
                end
            end
            context Array do
                it 'should be saved' do
                    p = @new_profile.call
                    p.exclude_vectors = @expected
                    p.exclude_vectors.should == @expected
                end
            end
        end
    end

    describe '#exclude_cookies=' do
        before { @expected = [ "include this", "this-too!" ] }
        context 'when the parameter is a' do
            context String do
                it 'should be parsed and converted to an Array before saving' do
                    p = @new_profile.call
                    p.exclude_cookies = "include this\nthis-too!"
                    p.exclude_cookies.should == @expected

                    p = @new_profile.call
                    p.exclude_cookies = "include this\n\rthis-too!"
                    p.exclude_cookies.should == @expected
                end
            end
            context Array do
                it 'should be saved' do
                    p = @new_profile.call
                    p.exclude_cookies = @expected
                    p.exclude_cookies.should == @expected
                end
            end
        end
    end

    describe '#cookies=' do
        before { @expected = { "sessionid" => "deadbeefbabe", "user" => "john.doe" } }
        context 'when the parameter is a' do
            context String do
                it 'should be parsed and converted to a Hash before saving' do
                    p = @new_profile.call
                    p.cookies = "sessionid=deadbeefbabe\nuser=john.doe"
                    p.cookies.should == @expected

                    p = @new_profile.call
                    p.cookies = "sessionid=deadbeefbabe\n\ruser=john.doe"
                    p.cookies.should == @expected
                end
            end
            context Hash do
                it 'should be saved' do
                    p = @new_profile.call
                    p.cookies = @expected
                    p.cookies.should == @expected
                end
            end
        end
    end

    describe '#custom_headers=' do
        before { @expected = { "From" => "john.dow@stuff.com", "X-Custom" => "hihihi" } }
        context 'when the parameter is a' do
            context String do
                it 'should be parsed and converted to a Hash before saving' do
                    p = @new_profile.call
                    p.custom_headers = "From=john.dow@stuff.com\nX-Custom=hihihi"
                    p.custom_headers.should == @expected

                    p = @new_profile.call
                    p.custom_headers = "From=john.dow@stuff.com\n\rX-Custom=hihihi"
                    p.custom_headers.should == @expected
                end
            end
            context Hash do
                it 'should be saved' do
                    p = @new_profile.call
                    p.custom_headers = @expected
                    p.custom_headers.should == @expected
                end
            end
        end
    end

    describe 'modules=' do
        context 'when the parameter is' do
            context :all do
                it 'should save all available modules' do
                    p = @new_profile.call
                    p.modules = :all
                    p.modules.should == ::FrameworkHelper.modules.keys
                end
            end
            context :default do
                it 'should save all available modules' do
                    p = @new_profile.call
                    p.modules = :default
                    p.modules.should == ::FrameworkHelper.modules.keys
                end
            end
            context Array do
                it 'should be saved' do
                    p = @new_profile.call
                    p.modules = [ :xss, 'sqli' ]
                    p.modules.should == [ :xss, 'sqli' ]
                end
            end
        end
    end

    describe 'plugins=' do
        context 'when the parameter is' do
            context :default do
                it 'should save all default plugins' do
                    p = @new_profile.call
                    p.modules = :default
                    p.modules.should == ::FrameworkHelper.modules.keys
                end
            end
            context Hash do
                it 'should be saved' do
                    p = @new_profile.call
                    p.modules = [ :xss, 'sqli' ]
                    p.modules.should == [ :xss, 'sqli' ]
                end
            end
        end
    end

end
