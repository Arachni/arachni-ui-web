class UpdateIssuesForFrameworkv05 < ActiveRecord::Migration
    def change
        remove_column :issues, :headers
        remove_column :issues, :audit_options

        add_column :issues, :vector_inputs, :text
        add_column :issues, :response,      :text
        add_column :issues, :request,       :text

        Issue.find_each.each do |issue|
            inputs = issue.schedule.audit_options[:params]
            next if !inputs

            Issue.update_all( { vector_inputs: inputs }, { id: issue.id } )
        end

    end
end
