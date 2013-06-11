# To create a user for this webapp, run the following from PG's SQL console:
#
#   CREATE USER arachni WITH PASSWORD 'secret' CREATEDB;
#
# (Update the settings bellow if you've changed the username or password values.)

development:
  host: localhost
  adapter: postgresql
  encoding: unicode
  database: arachni_development
  pool: 50
  username: arachni
  password: secret

test: &test
  host: localhost
  adapter: postgresql
  encoding: unicode
  database: arachni_test
  pool: 50
  username: arachni
  password: secret

production:
  host: localhost
  adapter: postgresql
  encoding: unicode
  database: arachni_production
  pool: 50
  username: arachni
  password: secret

cucumber:
  <<: *test
