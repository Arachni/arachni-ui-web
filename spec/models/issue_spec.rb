require 'spec_helper'

describe Issue do
    describe :factory do
        describe :issue do
            it 'creates a valid model' do
                FactoryGirl.create(:issue).should be_valid
            end
        end

        describe :issue_requiring_verification do
            it 'creates a valid model' do
                FactoryGirl.create(:issue_requiring_verification).should be_valid
            end
            it 'creates an Issue requiring manual verification' do
                FactoryGirl.create(:issue_requiring_verification).requires_verification.should be_true
            end
        end

        describe :issue_fixed do
            it 'creates a valid model' do
                FactoryGirl.create(:issue_fixed).should be_valid
            end
            it 'creates an Issue which has been marked as fixed' do
                FactoryGirl.create(:issue_fixed).fixed.should be_true
            end
        end

        describe :issue_verified do
            it 'creates a valid model' do
                FactoryGirl.create(:issue_verified).should be_valid
            end
            it 'creates an Issue which is needs manual verification' do
                FactoryGirl.create(:issue_verified).requires_verification.should be_true
            end
            it 'creates an Issue which has been marked as verified' do
                FactoryGirl.create(:issue_verified).verified.should be_true
                FactoryGirl.create(:issue_verified).verified?.should be_true
            end
        end

        describe :issue_false_positive do
            it 'creates a valid model' do
                FactoryGirl.create(:issue_false_positive).should be_valid
            end
            it 'creates an Issue which has been marked as a false positive' do
                FactoryGirl.create(:issue_false_positive).false_positive.should be_true
            end
        end

        describe :issue_with_verification_steps do
            it 'creates a valid model' do
                FactoryGirl.create(:issue_with_verification_steps).should be_valid
            end
            it 'creates an Issue which is needs manual verification' do
                FactoryGirl.create(:issue_with_verification_steps).requires_verification.should be_true
            end
            it 'creates an Issue which has verification steps' do
                FactoryGirl.create(:issue_with_verification_steps).verification_steps.should_not be_empty
            end
        end

        describe :issue_with_remediation_steps do
            it 'creates a valid model' do
                FactoryGirl.create(:issue_with_remediation_steps).should be_valid
            end
            it 'creates an Issue which has remediation steps' do
                FactoryGirl.create(:issue_with_remediation_steps).remediation_steps.should_not be_empty
            end
        end
    end

    describe :validation do
        it 'has a unique digest per Scan'
    end

    describe :scope do
        describe :default do
            it 'returns issues sorted by severity level'
        end

        describe :by_severity do
            it 'returns issues sorted by severity level'
        end

        describe :fixed do
            it 'returns issues marked as fixed'
        end

        describe :light do
            it 'returns issues without response bodies nor references'
        end

        describe :false_positives do
            it 'returns issues marked as false positives'
        end

        describe :verified do
            it 'returns issues marked as verified'
        end

        describe :pending_verification do
            it 'returns issues which are pending verification   '
        end
    end

    describe '.describe_notification' do
        it 'returns a description for the given notification action'
    end

    describe '#timeline' do
        it 'returns a timeline of notifications for the issue'
    end

    describe '#url' do
        it 'returns the URL'
        context 'when the URL is empty' do
            it 'returns nil'
        end
    end

    describe '#seed' do
        it 'returns the seed'
        context 'when the seed is empty' do
            it 'returns nil'
        end
    end

    describe '#proof' do
        it 'returns the proof'
        context 'when the proof is empty' do
            it 'returns nil'
        end
    end

    describe '#response_body' do
        it 'returns the response_body'
        context 'when the response_body is empty' do
            it 'returns nil'
        end
    end

    describe '#signature' do
        it 'returns the signature'
        context 'when the signature is empty' do
            it 'returns nil'
        end
    end

    describe '#signature' do
        it 'returns the signature'
        context 'when the signature is empty' do
            it 'returns nil'
        end
    end

    describe '#verified?' do
        context 'when the issue has been verified' do
            context 'and is not a false positive' do
                it 'returns true'
            end
        end
    end

    describe '#pending_verification?' do
        context 'when the issue needs manual verification' do
            context 'and is not verified' do
                context 'and is not a false positive' do
                    context 'and is not fixed' do
                        it 'returns true'
                    end
                end
            end
        end
    end

    describe '#pending_review?' do
        context 'when the issue needs manual verification' do
            context 'and is not verified' do
                context 'and is not a false positive' do
                    context 'and does not require verification' do
                        context 'and is not fixed' do
                            it 'returns true'
                        end
                    end
                end
            end
        end
    end

    describe '#requires_verification_and_verified?' do
        context 'when the issue needs manual verification' do
            context 'and is verified' do
                context 'and is not a false positive' do
                    it 'returns true'
                end
            end
        end
    end

    describe '#has_verification_steps?' do
        context 'when the issue has verification steps' do
            it 'should return true'
        end
    end

    describe '#has_remediation_steps?' do
        context 'when the issue has remediation steps' do
            it 'should return true'
        end
    end

    describe '#response_body_contains_proof?' do
        context 'when the issue has a proof' do
            context 'and a response_body' do
                context 'and the response_body contains the proof' do
                    it 'returns true'
                end
            end
        end
    end

    describe '#base64_response_body' do
        it 'returns the response body in Base64 encoding'
    end

    describe '#to_s' do
        it 'returns a string representation of the issue'
    end

    describe '#cwe_url' do
        it 'returns the CWE URL'
    end

    describe '#subscribers' do
        it 'returns the parent scan\'s subscribers'
    end

    describe '#family' do
        it 'returns nested family list from the child (self) to the oldest ancestor'
    end

    describe '.describe_notification' do
        it 'returns a description for the given notification action'
    end

    describe '.create_from_framework_issue' do
        it 'creates an Issue model from an Arachni::Issue'
    end

    describe '.update_from_framework_issue' do
        it 'updates an Issue model from an Arachni::Issue'
    end

    describe '.translate_framework_issue' do
        it 'translates an Arachni::Issue to an Issue model'
    end
end
