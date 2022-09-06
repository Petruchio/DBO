require 'pg'            # Presently PostgreSQL only.
require 'sequel'
require 'dbo/profile'
require 'dbo/base'
require 'dbo/database'  # Is this the right place to do this?

module DBO
	class Connection < Base

		# Presently, only one connection per profile is possible.
		@pool = {}

		class << self
			attr_reader :pool
		end

		def initialize profile
			key = profile.to_sym

			if self.class.pool.has_key? key
				warn "Ignoring request: connection to #{profile} already exists."
				return self.class.pool[key]
			end

			prof     = DBO::Profile[key]
			@main_db = prof[:database]
			url      = prof.to_url
			@db      = Sequel.connect url
			self.class.pool[profile] = self
		end

		def query sql
			@db[sql]
		end

		# Should get the SQL into templates...

		def databases
			db_names = @db['SELECT datname FROM pg_database'].to_a
		end

		def database
			DBO::Database.new name: @main_db, connection: self
		end

	end
end
