# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_pumpdump_session',
  :secret      => '6cfe080873a55ddedc1dc1904c299d2f0bf550234b10569c3dce466256667bee8f79b4bfb697653c226053d51d0ff31e8587343699370108b7cc7fcfd45b49ed'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
