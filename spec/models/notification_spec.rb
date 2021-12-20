require 'spec_helper'

describe Notification do
    describe :factory do
        describe :notification do
            it 'creates a valid model' do
                FactoryBot.create(:notification).should be_valid
            end
            it 'creates an unread notification' do
                FactoryBot.create(:notification).read.should be_false
            end
        end

        describe :notification_read do
            it 'creates a valid model' do
                FactoryBot.create(:notification_read).should be_valid
            end
            it 'creates a read notification' do
                FactoryBot.create(:notification_read).read.should be_true
            end
        end
    end

    describe :validation do
    end

    describe :scope do
        describe :read do
            it 'returns read notifications' do
                3.times { FactoryBot.create(:notification) }
                read = (0..2).map { FactoryBot.create(:notification_read) }

                Notification.read.should =~ read
            end
        end
        describe :unread do
            it 'returns unread notifications' do
                3.times { FactoryBot.create(:notification_read) }
                unread = (0..2).map { FactoryBot.create(:notification) }

                Notification.unread.should =~ unread
            end
        end
    end

    describe '.mark_read' do
        it 'marks all notifications as read' do
            3.times { FactoryBot.create(:notification) }

            Notification.unread.should be_any
            Notification.read.should be_empty

            Notification.mark_read

            Notification.unread.should be_empty
            Notification.read.should be_any
        end
    end

    describe '#unread?' do
        context 'when the notification is not read' do
            it 'returns true' do
                FactoryBot.create(:notification).unread?.should be_true
            end
        end
        context 'when the notification is read' do
            it 'returns false' do
                FactoryBot.create(:notification_read).unread?.should be_false
            end
        end
    end

    describe '#model=' do
        it 'sets the model which triggered the notification' do
            n = FactoryBot.create(:notification)
            i = FactoryBot.create(:issue)

            n.model = i
            n.model.should == i
        end
    end

    describe '#model' do
        it 'returns the model which triggered the notification' do
            i = FactoryBot.create(:issue)
            n = FactoryBot.create(:notification, model: i )

            n.model.should == i
        end

        context 'when the model has been deleted' do
            it 'returns nil' do
                i = FactoryBot.create(:issue)
                n = FactoryBot.create(:notification, model: i )

                i.destroy
                n.model.should be_nil
            end
        end
    end

    describe '#model_class' do
        it 'returns the class of the model which triggered the notification' do
            n = FactoryBot.create(:notification)
            n.model = FactoryBot.create(:issue)
            n.model_class.should == Issue
        end
    end

    describe '#action' do
        it 'returns the action as a symbol' do
            n = FactoryBot.create(:notification, action: 'destroy' )
            n.action.should == :destroy
        end
    end

    describe '#action_description' do
        it 'returns a description for the current action' do
            i = FactoryBot.create(:issue)
            n = FactoryBot.create( :notification, model: i, action: 'destroy' )

            n.action_description.should == Issue.describe_notification( n.action )
        end
    end

    describe :to_s do
        it 'returns a string representation of the notification' do
            FactoryBot.create( :notification,
                                model:   FactoryBot.create(:issue),
                                action: 'create' ).to_s.should_not be_empty
        end

        context 'when the model exists' do
            it 'includes the model class' do
                FactoryBot.create( :notification,
                                    model:   FactoryBot.create(:issue),
                                    action: 'create' ).to_s.should include('Issue')
            end
        end

        context 'when the model no longer exists' do
            it 'includes its numeric ID' do
                i = FactoryBot.create(:issue)
                n = FactoryBot.create( :notification,
                                        model:  i,
                                        action: 'create' )

                id = i.id
                i.destroy
                n.reload

                n.to_s.should include(id.to_s)
            end
        end

        it 'includes the string representation of the model' do
            i = FactoryBot.create(:issue)
            FactoryBot.create( :notification,
                                model:  i,
                                action: 'create' ).to_s.should include(i.to_s)
        end

        it 'includes the description of the action' do
            n = FactoryBot.create( :notification,
                                    model:  FactoryBot.create(:issue),
                                    action: 'destroy' )

            n.to_s.should include(n.action_description)
        end

        context 'when the actor user exists' do
            it 'includes the actor' do
                n = FactoryBot.create( :notification,
                                        model:  FactoryBot.create(:issue),
                                        action: 'destroy' )

                n.to_s.should include(n.actor.to_s)
            end
        end

        context 'when the actor user no longer exists' do
            it 'does not include the actor' do
                n = FactoryBot.create( :notification,
                                        model:  FactoryBot.create(:issue),
                                        action: 'destroy' )

                name = n.actor.to_s
                n.actor.destroy
                n.reload

                n.to_s.should_not include(name)
            end
        end
    end
end
