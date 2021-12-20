require 'spec_helper'

describe Comment do

    describe :factory do
        describe :comment do
            it 'creates a valid model' do
                FactoryBot.create(:comment).should be_valid
            end
        end
    end

    describe :validation do
        describe :text do
            context 'when nil' do
                it 'is invalid' do
                    FactoryBot.build( :comment, text: nil ).should be_invalid
                end
            end

            context 'when empty' do
                it 'is invalid' do
                    FactoryBot.build( :comment, text: '' ).should be_invalid
                end
            end

            context 'when it contains HTML' do
                it 'is invalid' do
                    FactoryBot.build( :comment, text: '<em>Stuff...<em>' ).
                        should be_invalid
                end
            end
        end
    end

    describe '#text' do
        it 'returns the comment text' do
            text = Faker::Lorem.paragraph
            comment = FactoryBot.create( :comment, text: text )

            comment.should be_valid
            comment.text.should == text
        end
    end

    describe '#commentable' do
        it 'returns the parent object' do
            comment = FactoryBot.create(:comment)
            comment.commentable.should be_a_kind_of(Issue)
        end
    end

end
