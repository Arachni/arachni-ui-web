class UpdateProfileForFrameworkv10 < ActiveRecord::Migration[4.2]
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
            auto_redundant:    :scope_auto_redundant_paths,
            https_only:        :scope_https_only,
            fuzz_methods:      :audit_with_both_http_methods,
            exclude_vectors:   :audit_exclude_vector_patterns,
            modules:           :checks,
            max_slaves:        :spawns,
            authed_by:         :authorized_by,
            login_check_url:   :session_check_url,
            login_check_pattern: :session_check_pattern
        }.each { |k, v| rename_column :profiles, k, v }

        remove_column :profiles, :exclude_cookies

        add_column :profiles, :input_values,         :text
        add_column :profiles, :audit_link_templates, :text
        add_column :profiles, :audit_include_vector_patterns,  :text

        add_column :profiles, :scope_url_rewrites,    :text
        add_column :profiles, :scope_dom_depth_limit, :integer

        add_column :profiles, :browser_cluster_pool_size,           :integer
        add_column :profiles, :browser_cluster_job_timeout,         :integer
        add_column :profiles, :browser_cluster_worker_time_to_live, :integer
        add_column :profiles, :browser_cluster_ignore_images,       :boolean
        add_column :profiles, :browser_cluster_screen_width,        :integer
        add_column :profiles, :browser_cluster_screen_height,       :integer

        Profile.update_all(
            scope_dom_depth_limit:               Arachni::Options.scope.dom_depth_limit,
            browser_cluster_pool_size:           Arachni::Options.browser_cluster.pool_size,
            browser_cluster_job_timeout:         Arachni::Options.browser_cluster.job_timeout,
            browser_cluster_worker_time_to_live: Arachni::Options.browser_cluster.worker_time_to_live,
            browser_cluster_ignore_images:       Arachni::Options.browser_cluster.ignore_images,
            browser_cluster_screen_width:        Arachni::Options.browser_cluster.screen_width,
            browser_cluster_screen_height:       Arachni::Options.browser_cluster.screen_height
        )
    end
end
