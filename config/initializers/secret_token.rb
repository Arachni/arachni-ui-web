# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Generate a random secret on first run.
secret_token_file = File.expand_path( '../secret_token', __FILE__ )

if !File.exist?( secret_token_file )
    token = (0...200).map{ ((0..9).to_a | ('a'..'h').to_a).to_a[rand(26)] }.join
    File.open( secret_token_file, 'w' ) { |f| f.write token }
end

ArachniWebui::Application.config.secret_key_base = IO.read( secret_token_file )
