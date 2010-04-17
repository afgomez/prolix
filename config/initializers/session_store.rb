# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_prolix_session',
  :secret      => 'a0b36a16de54704af93dbf855309d7bd960ec673fb17c2d6c07ac1daf1e160abfd7cf2bd325d55b4a7f8a67c4aef789b0fe1f6a5a692f48c6c44e865ee2e0de0'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
