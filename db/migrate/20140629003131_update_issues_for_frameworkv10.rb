class UpdateIssuesForFrameworkv10 < ActiveRecord::Migration
    def change
        remove_column :issues, :headers

        add_column :issues, :vector_inputs,   :text
        add_column :issues, :vector_html,     :text
        add_column :issues, :dom_transitions, :text
        add_column :issues, :dom_body,        :text
        add_column :issues, :response,        :text
        add_column :issues, :request,         :text

        (Issue.find_each || []).each do |issue|
            sql = "SELECT * from issues WHERE \"id\"=#{issue.id}"
            result = ActiveRecord::Base.connection.execute(sql)

            audit_options = result.first['audit_options']
            next if !audit_options

            audit_options = YAML.load( audit_options )

            inputs = audit_options['params']
            next if !inputs

            Issue.where( id: issue.id ).update_all( vector_inputs: inputs )
        end

        remove_column :issues, :audit_options
    end
end
