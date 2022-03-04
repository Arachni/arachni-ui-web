require 'spec_helper'

describe Issue do
    #
    # before :each do
    #     @issue_data = {
    #         name: 'Module name',
    #         elem: Arachni::Element::LINK,
    #         method: 'GET',
    #         description: 'Issue description',
    #         references: {
    #             'Title' => 'http://some/url'
    #         },
    #         cwe: '1',
    #         severity: Arachni::Issue::Severity::HIGH,
    #         cvssv2: '4.5',
    #         remedy_guidance: 'How to fix the issue.',
    #         remedy_code: 'Sample code on how to fix the issue',
    #         verification: false,
    #         metasploitable: 'exploit/unix/webapp/php_include',
    #         opts: { 'some' => 'opts' },
    #         mod_name: 'Module name',
    #         internal_modname: 'module_name',
    #         tags: %w(these are a few tags),
    #         var: 'input name',
    #         url: 'http://test.com/stuff/test.blah?query=blah',
    #         headers: {
    #             request: {
    #                 'User-Agent' => 'UA/v1'
    #             },
    #             response: {
    #                 'Set-Cookie' => 'name=value'
    #             }
    #         },
    #         remarks: {
    #             the_dude: ['Hey!']
    #         },
    #         response: 'HTML response',
    #         injected: 'injected string',
    #         id: 'This string was used to identify the vulnerability',
    #         regexp: /some regexp/,
    #         regexp_match: "string matched by '/some regexp/'"
    #     }
    #
    #     @issue = Arachni::Issue.new( @issue_data.deep_clone )
    # end
    #
    # describe :factory do
    #     describe :issue do
    #         it 'creates a valid model' do
    #             FactoryBot.create(:issue).should be_valid
    #         end
    #     end
    #
    #     describe :issue_requiring_verification do
    #         it 'creates a valid model' do
    #             FactoryBot.create(:issue_requiring_verification).should be_valid
    #         end
    #         it 'creates an Issue requiring manual verification' do
    #             FactoryBot.create(:issue_requiring_verification).requires_verification.should be_true
    #         end
    #     end
    #
    #     describe :issue_fixed do
    #         it 'creates a valid model' do
    #             FactoryBot.create(:issue_fixed).should be_valid
    #         end
    #         it 'creates an Issue which has been marked as fixed' do
    #             FactoryBot.create(:issue_fixed).fixed.should be_true
    #         end
    #     end
    #
    #     describe :issue_verified do
    #         it 'creates a valid model' do
    #             FactoryBot.create(:issue_verified).should be_valid
    #         end
    #         it 'creates an Issue which is needs manual verification' do
    #             FactoryBot.create(:issue_verified).requires_verification.should be_true
    #         end
    #         it 'creates an Issue which has been marked as verified' do
    #             FactoryBot.create(:issue_verified).verified.should be_true
    #             FactoryBot.create(:issue_verified).verified?.should be_true
    #         end
    #     end
    #
    #     describe :issue_false_positive do
    #         it 'creates a valid model' do
    #             FactoryBot.create(:issue_false_positive).should be_valid
    #         end
    #         it 'creates an Issue which has been marked as a false positive' do
    #             FactoryBot.create(:issue_false_positive).false_positive.should be_true
    #         end
    #     end
    #
    #     describe :issue_with_verification_steps do
    #         it 'creates a valid model' do
    #             FactoryBot.create(:issue_with_verification_steps).should be_valid
    #         end
    #         it 'creates an Issue which is needs manual verification' do
    #             FactoryBot.create(:issue_with_verification_steps).requires_verification.should be_true
    #         end
    #         it 'creates an Issue which has verification steps' do
    #             FactoryBot.create(:issue_with_verification_steps).verification_steps.should_not be_empty
    #         end
    #     end
    #
    #     describe :issue_with_remediation_steps do
    #         it 'creates a valid model' do
    #             FactoryBot.create(:issue_with_remediation_steps).should be_valid
    #         end
    #         it 'creates an Issue which has remediation steps' do
    #             FactoryBot.create(:issue_with_remediation_steps).remediation_steps.should_not be_empty
    #         end
    #     end
    # end
    #
    # describe :validation do
    #     it 'has a unique digest per Scan'
    #
    #     describe :verification_steps do
    #         it 'should be invalid with HTML markup' do
    #             FactoryBot.build( :issue, verification_steps: '<em>stuff</em>' ).should be_invalid
    #         end
    #         it 'should be valid without HTML markup' do
    #             FactoryBot.build( :issue, verification_steps: 'stuff' ).should be_valid
    #         end
    #     end
    #     describe :remediation_steps do
    #         it 'should be invalid with HTML markup' do
    #             FactoryBot.build( :issue, remediation_steps: '<em>stuff</em>' ).should be_invalid
    #         end
    #         it 'should be valid without HTML markup' do
    #             FactoryBot.build( :issue, remediation_steps: 'stuff' ).should be_valid
    #         end
    #     end
    # end
    #
    # describe :scope do
    #     describe :default do
    #         it 'returns issues sorted by severity level' do
    #             FactoryBot.create( :issue, severity: Arachni::Issue::Severity::HIGH )
    #             FactoryBot.create( :issue, severity: Arachni::Issue::Severity::INFORMATIONAL )
    #             FactoryBot.create( :issue, severity: Arachni::Issue::Severity::LOW )
    #             FactoryBot.create( :issue, severity: Arachni::Issue::Severity::MEDIUM )
    #
    #             Issue.all.pluck( :severity ).should == Issue::ORDERED_SEVERITIES
    #         end
    #     end
    #
    #     describe :by_severity do
    #         it 'returns issues sorted by severity level' do
    #             FactoryBot.create( :issue, severity: Arachni::Issue::Severity::HIGH )
    #             FactoryBot.create( :issue, severity: Arachni::Issue::Severity::INFORMATIONAL )
    #             FactoryBot.create( :issue, severity: Arachni::Issue::Severity::LOW )
    #             FactoryBot.create( :issue, severity: Arachni::Issue::Severity::MEDIUM )
    #
    #             Issue.all.pluck( :severity ).should == Issue::ORDERED_SEVERITIES
    #         end
    #     end
    #
    #     describe :fixed do
    #         it 'returns issues marked as fixed' do
    #             3.times { FactoryBot.create( :issue ) }
    #             fixed = (0..2).map { FactoryBot.create( :issue, fixed: true ) }
    #
    #             Issue.fixed.should =~ fixed
    #         end
    #     end
    #
    #     describe :light do
    #         it 'returns issues without response_body nor references' do
    #             FactoryBot.create( :issue )
    #             i = Issue.light.first
    #
    #             i.attributes.keys.should_not include( *%w(response_body references) )
    #         end
    #     end
    #
    #     describe :false_positives do
    #         it 'returns issues marked as false positives' do
    #             3.times { FactoryBot.create( :issue ) }
    #             false_positives = (0..2).map { FactoryBot.create( :issue, false_positive: true ) }
    #
    #             Issue.false_positives.should =~ false_positives
    #         end
    #     end
    #
    #     describe :verified do
    #         it 'returns issues which require verification and have verified' do
    #             3.times { FactoryBot.create( :issue ) }
    #             3.times { FactoryBot.create( :issue_requiring_verification ) }
    #             verified = (0..2).map { FactoryBot.create( :issue_requiring_verification,
    #                                                         verified: true ) }
    #
    #             Issue.verified.should =~ verified
    #         end
    #     end
    #
    #     describe :pending_verification do
    #         it 'returns issues which are pending verification' do
    #             3.times { FactoryBot.create( :issue ) }
    #             pending = (0..2).map { FactoryBot.create( :issue_requiring_verification ) }
    #
    #             Issue.pending_verification.should =~ pending
    #         end
    #     end
    # end
    #
    # describe '#timeline' do
    #     it 'returns a timeline of notifications for the issue'
    # end
    #
    # describe '#url' do
    #     it 'returns the URL' do
    #         FactoryBot.create( :issue ).url.should_not be_empty
    #     end
    #     context 'when the URL is empty' do
    #         it 'returns nil' do
    #             FactoryBot.create( :issue, url: '' ).url.should be_nil
    #         end
    #     end
    # end
    #
    # describe '#seed' do
    #     it 'returns the seed' do
    #         FactoryBot.create( :issue ).seed.should_not be_empty
    #     end
    #     context 'when the seed is empty' do
    #         it 'returns nil' do
    #             FactoryBot.create( :issue, seed: '' ).seed.should be_nil
    #         end
    #     end
    # end
    #
    # describe '#proof' do
    #     it 'returns the proof' do
    #         FactoryBot.create( :issue ).proof.should_not be_empty
    #     end
    #     context 'when the proof is empty' do
    #         it 'returns nil' do
    #             FactoryBot.create( :issue, proof: '' ).proof.should be_nil
    #         end
    #     end
    # end
    #
    # describe '#response_body' do
    #     it 'returns the response_body' do
    #         FactoryBot.create( :issue ).response_body.should_not be_empty
    #     end
    #     context 'when the response_body is empty' do
    #         it 'returns nil' do
    #             FactoryBot.create( :issue, response_body: '' ).response_body.should be_nil
    #         end
    #     end
    # end
    #
    # describe '#signature' do
    #     it 'returns the signature' do
    #         FactoryBot.create( :issue ).signature.should_not be_empty
    #     end
    #     context 'when the signature is empty' do
    #         it 'returns nil' do
    #             FactoryBot.create( :issue, signature: '' ).signature.should be_nil
    #         end
    #     end
    # end
    #
    # describe '#verified?' do
    #     context 'when the issue has been verified' do
    #         context 'and is not a false positive' do
    #             it 'returns true' do
    #                 FactoryBot.create( :issue,
    #                                     verified:       true,
    #                                     false_positive: false ).
    #                     verified?.should be_true
    #             end
    #         end
    #
    #         context 'and is a false positive' do
    #             it 'should be invalid' do
    #                 FactoryBot.build( :issue,
    #                                     verified:       true,
    #                                     false_positive: true ).should be_invalid
    #             end
    #         end
    #     end
    #
    #     it 'returns false' do
    #         FactoryBot.create( :issue ).verified?.should be_false
    #     end
    # end
    #
    # describe '#pending_verification?' do
    #     it 'returns false' do
    #         FactoryBot.create( :issue ).pending_verification?.should be_false
    #     end
    #
    #     context 'when the issue needs manual verification' do
    #         context 'and is not verified' do
    #             context 'and is not a false positive' do
    #                 context 'and is not fixed' do
    #                     it 'returns true' do
    #                         FactoryBot.create( :issue_requiring_verification,
    #                                             verified:       false,
    #                                             false_positive: false,
    #                                             fixed:          false ).
    #                             pending_verification?.should be_true
    #                     end
    #                 end
    #
    #                 context 'and is fixed' do
    #                     it 'returns false' do
    #                         FactoryBot.build( :issue_requiring_verification,
    #                                            fixed: true ).
    #                             pending_verification?.should be_false
    #                     end
    #                 end
    #             end
    #
    #             context 'and is a false positive' do
    #                 it 'returns false' do
    #                     FactoryBot.build( :issue_requiring_verification,
    #                                         false_positive: true ).should be_invalid
    #                 end
    #             end
    #         end
    #
    #         context 'and is verified' do
    #             it 'returns false' do
    #                 FactoryBot.create( :issue_requiring_verification,
    #                                     verified: true ).
    #                     pending_verification?.should be_false
    #             end
    #         end
    #     end
    # end
    #
    # describe '#pending_review?' do
    #     context 'when the issue does not need manual verification' do
    #         context 'and is not verified' do
    #             context 'and is not a false positive' do
    #                 context 'and is not fixed' do
    #                     it 'returns true' do
    #                         FactoryBot.create( :issue,
    #                                             requires_verification: false,
    #                                             verified:              false,
    #                                             false_positive:        false,
    #                                             fixed:                 false ).
    #                             pending_review?.should be_true
    #                     end
    #                 end
    #             end
    #         end
    #     end
    #
    #     context 'when the issue needs manual verification' do
    #         it 'returns false' do
    #             FactoryBot.create( :issue_requiring_verification ).
    #                 pending_review?.should be_false
    #         end
    #     end
    #
    #     context 'when the issue is verified' do
    #         it 'returns false' do
    #             FactoryBot.create( :issue_verified ).pending_review?.should be_false
    #         end
    #     end
    #
    #     context 'when the issue is a false positive' do
    #         it 'returns false' do
    #             FactoryBot.create( :issue_false_positive ).pending_review?.should be_false
    #         end
    #     end
    #
    #     context 'when the issue is fixed' do
    #         it 'returns false' do
    #             FactoryBot.create( :issue_fixed ).pending_review?.should be_false
    #         end
    #     end
    #
    # end
    #
    # describe '#requires_verification_and_verified?' do
    #     context 'when the issue needs manual verification' do
    #         context 'and is verified' do
    #             context 'and is not a false positive' do
    #                 it 'returns true' do
    #                     FactoryBot.create( :issue_requiring_verification,
    #                                         verified:       true,
    #                                         false_positive: false ).
    #                         requires_verification_and_verified?.should be_true
    #                 end
    #             end
    #         end
    #     end
    # end
    #
    # describe '#has_verification_steps?' do
    #     context 'when the issue has verification steps' do
    #         it 'returns true' do
    #             FactoryBot.create( :issue_with_verification_steps ).
    #                 has_verification_steps?.should be_true
    #         end
    #     end
    #
    #     context 'when the issue does not have verification steps' do
    #         it 'returns false' do
    #             FactoryBot.create( :issue, verification_steps: nil ).
    #                 has_verification_steps?.should be_false
    #         end
    #     end
    # end
    #
    # describe '#has_remediation_steps?' do
    #     context 'when the issue has remediation steps' do
    #         it 'returns true' do
    #             FactoryBot.create( :issue_with_remediation_steps ).
    #                 has_remediation_steps?.should be_true
    #         end
    #     end
    #
    #     context 'when the issue does not have remediation steps' do
    #         it 'returns false' do
    #             FactoryBot.create( :issue, remediation_steps: nil ).
    #                 has_remediation_steps?.should be_false
    #         end
    #     end
    # end
    #
    # describe '#response_contains_proof?' do
    #     context 'when the issue has a proof' do
    #         context 'and a response_body' do
    #             context 'and the response_body contains the proof' do
    #                 it 'returns true' do
    #                     FactoryBot.create( :issue,
    #                                         response_body: 'stuff here!',
    #                                         proof: 'stuff' ).
    #                         response_contains_proof?.should be_true
    #                 end
    #             end
    #             context 'and the response_body does not contain the proof' do
    #                 it 'returns true' do
    #                     FactoryBot.create( :issue,
    #                                         response_body: 'stuff here!',
    #                                         proof: 'stufff' ).
    #                         response_contains_proof?.should be_false
    #                 end
    #             end
    #         end
    #     end
    #
    #     context 'when the issue has no response body' do
    #         it 'returns false' do
    #             FactoryBot.create( :issue,
    #                                 response_body: nil,
    #                                 proof: 'stuff' ).
    #                 response_contains_proof?.should be_false
    #         end
    #     end
    #
    #     context 'when the issue has no proof' do
    #         it 'returns false' do
    #             FactoryBot.create( :issue,
    #                                 response_body: 'stuff here!',
    #                                 proof: nil ).
    #                 response_contains_proof?.should be_false
    #         end
    #     end
    # end
    #
    # describe '#base64_response_body' do
    #     it 'returns the response body in Base64 encoding' do
    #         i = FactoryBot.create( :issue )
    #         Base64.decode64( i.base64_response_body ).should == i.response_body
    #     end
    # end
    #
    # describe '#to_s' do
    #     it 'contains the issue name' do
    #         i = FactoryBot.create( :issue )
    #         i.to_s.should include( i.name )
    #     end
    #     it 'contains the capitalized vector type' do
    #         i = FactoryBot.create( :issue )
    #         i.to_s.should include( i.vector_type.capitalize )
    #     end
    #
    #     context 'when there is a vector name' do
    #         it 'contains the vector name' do
    #             i = FactoryBot.create( :issue )
    #             i.to_s.should include( i.vector_name )
    #         end
    #     end
    #
    #     context 'when there is novector name' do
    #         it 'does not contain the vector name' do
    #             i = FactoryBot.create( :issue, vector_name: '' )
    #             i.to_s.should include( i.vector_name )
    #         end
    #     end
    #
    # end
    #
    # describe '#cwe_url' do
    #     context 'when there is a CWE identifier' do
    #         it 'returns the CWE URL' do
    #             FactoryBot.create( :issue ).cwe_url.should_not be_empty
    #         end
    #     end
    #
    #     context 'when there is no CWE identifier' do
    #         it 'returns nil' do
    #             FactoryBot.create( :issue, cwe: nil ).cwe_url.should be_nil
    #         end
    #     end
    # end
    #
    # describe '#subscribers' do
    #     it 'returns the parent scan\'s subscribers'
    # end
    #
    # describe '#family' do
    #     it 'returns nested family list from the child (self) to the oldest ancestor'
    # end
    #
    # describe '.describe_notification' do
    #     context 'when action is' do
    #         [ :destroy, :update, :reviewed, :verified, :fixed, :false_positive,
    #             :requires_verification, :verification_steps, :remediation_steps,
    #             :commented ].each do |action|
    #             describe action do
    #                 it "returns a description for the #{action} action" do
    #                     Issue.describe_notification( action ).should_not be_empty
    #                 end
    #             end
    #         end
    #     end
    #
    #     context 'when action is unknown' do
    #         it 'returns nil' do
    #             Issue.describe_notification( :blahblahblah ).should be_nil
    #         end
    #     end
    # end
    #
    # describe '.create_from_framework_issue' do
    #     it 'creates an Issue model from an Arachni::Issue' do
    #         i = Issue.create_from_framework_issue( @issue )
    #
    #         i.name.should == @issue.name
    #         i.url.should == @issue.url
    #         i.vector_name.should == @issue.var
    #         i.vector_type.should == @issue.elem
    #         i.cvssv2.to_s.should == @issue.cvssv2
    #         i.cwe.should == @issue.cwe.to_i
    #         i.description.should == @issue.description
    #         i.http_method.should == @issue.method
    #         i.tags.should == @issue.tags
    #         i.headers.should == @issue.headers
    #         i.references.should == @issue.references
    #         i.remedy_code.should == @issue.remedy_code
    #         i.remedy_guidance.should == @issue.remedy_guidance
    #         i.remarks.should == @issue.remarks
    #         i.severity.should == @issue.severity
    #         i.digest.should == @issue.digest
    #     end
    # end
    #
    # describe '.update_from_framework_issue' do
    #     it 'updates an Issue model from an Arachni::Issue' do
    #         i = Issue.create_from_framework_issue( @issue )
    #
    #         i.name.should == @issue.name
    #         i.url.should == @issue.url
    #         i.vector_name.should == @issue.var
    #         i.vector_type.should == @issue.elem
    #         i.cvssv2.to_s.should == @issue.cvssv2
    #         i.cwe.should == @issue.cwe.to_i
    #         i.description.should == @issue.description
    #         i.http_method.should == @issue.method
    #         i.tags.should == @issue.tags
    #         i.headers.should == @issue.headers
    #         i.references.should == @issue.references
    #         i.remedy_code.should == @issue.remedy_code
    #         i.remedy_guidance.should == @issue.remedy_guidance
    #         i.remarks.should == @issue.remarks
    #         i.severity.should == @issue.severity
    #         i.digest.should == @issue.digest
    #
    #         updated_name = 'Updated name'
    #         @issue.name = updated_name
    #
    #         Issue.update_from_framework_issue( @issue )
    #         i.reload
    #
    #         i.name.should == updated_name
    #         i.url.should == @issue.url
    #         i.vector_name.should == @issue.var
    #         i.vector_type.should == @issue.elem
    #         i.cvssv2.to_s.should == @issue.cvssv2
    #         i.cwe.should == @issue.cwe.to_i
    #         i.description.should == @issue.description
    #         i.http_method.should == @issue.method
    #         i.tags.should == @issue.tags
    #         i.headers.should == @issue.headers
    #         i.references.should == @issue.references
    #         i.remedy_code.should == @issue.remedy_code
    #         i.remedy_guidance.should == @issue.remedy_guidance
    #         i.remarks.should == @issue.remarks
    #         i.severity.should == @issue.severity
    #         i.digest.should == @issue.digest
    #     end
    # end
    #
    # describe '.translate_framework_issue' do
    #     it 'translates an Arachni::Issue to a hash suitable for an Issue model' do
    #         i = Issue.create( Issue.translate_framework_issue( @issue ) )
    #
    #         i.name.should == @issue.name
    #         i.url.should == @issue.url
    #         i.vector_name.should == @issue.var
    #         i.vector_type.should == @issue.elem
    #         i.cvssv2.to_s.should == @issue.cvssv2
    #         i.cwe.should == @issue.cwe.to_i
    #         i.description.should == @issue.description
    #         i.http_method.should == @issue.method
    #         i.tags.should == @issue.tags
    #         i.headers.should == @issue.headers
    #         i.references.should == @issue.references
    #         i.remedy_code.should == @issue.remedy_code
    #         i.remedy_guidance.should == @issue.remedy_guidance
    #         i.remarks.should == @issue.remarks
    #         i.severity.should == @issue.severity
    #         i.digest.should == @issue.digest
    #     end
    # end
end
