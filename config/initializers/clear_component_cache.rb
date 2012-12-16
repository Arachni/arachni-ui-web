glob = File.join( Rails.root, 'config', 'component_cache', "*.yml" )
Dir.glob( glob ).each { |f| File.delete f }
