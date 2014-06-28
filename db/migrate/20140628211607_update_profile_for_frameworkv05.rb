class UpdateProfileForFrameworkv05 < ActiveRecord::Migration
    def change
        {
            redirect_limit:    :http_request_redirect_limit,
            http_req_limit:    :http_request_concurrency,
            custom_headers:    :http_request_headers,
            http_timeout:      :http_request_timeout,
            http_queue_size:   :http_request_queue_size,
            proxy_host:        :http_proxy_host,
            proxy_port:        :http_proxy_port,
            proxy_username:    :http_proxy_username,
            proxy_password:    :http_proxy_password,
            proxy_type:        :http_proxy_type,
            http_username:     :http_authentication_username,
            http_password:     :http_authentication_password,
            cookies:           :http_cookies,
            user_agent:        :http_user_agent,
            exclude:           :scope_exclude_path_patterns,
            exclude_pages:     :scope_exclude_content_patterns,
            exclude_binaries:  :scope_exclude_binaries,
            include:           :scope_include_path_patterns,
            follow_subdomains: :scope_include_subdomains,
            restrict_paths:    :scope_restrict_paths,
            extend_paths:      :scope_extend_paths,
            redundant:         :scope_redundant_path_patterns,
            depth_limit:       :scope_directory_depth_limit,
            link_count_limit:  :scope_page_limit,
            auto_redundant:    :scope_auto_redundant,
            https_only:        :scope_https_only,
            fuzz_methods:      :audit_with_both_http_methods,
            exclude_vectors:   :audit_exclude_vectors,
            modules:           :checks,
            max_slaves:        :spawns,
            authed_by:         :authorized_by,
        }.each { |k, v| rename_column :profiles, k, v }

        remove_column :profiles, :audit_exclude_cookies
    end
end
