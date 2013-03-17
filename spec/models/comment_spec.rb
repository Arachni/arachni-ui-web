require 'spec_helper'

describe Comment do

    it 'should have a valid factory' do
        FactoryGirl.create(:comment).should be_valid
    end

    describe 'validation' do
        it 'is invalid without :text' do
            FactoryGirl.build( :comment, text: nil ).should be_invalid
        end

        it 'is invalid with empty :text' do
            FactoryGirl.build( :comment, text: '' ).should be_invalid
        end

        it 'is invalid with HTML in :text' do
            FactoryGirl.build( :comment, text: '<em>Stuff...<em>' ).should be_invalid
        end
    end

    describe '#text' do
        it 'returns the comment text' do
            text = Faker::Lorem.paragraph
            comment = FactoryGirl.create( :comment, text: text )

            comment.should be_valid
            comment.text.should == text
        end
    end

    describe '#commentable' do
        it 'returns the parent object' do
            comment = FactoryGirl.create(:comment)
            comment.commentable.should be_a_kind_of(Issue)
        end
    end

end
