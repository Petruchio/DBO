require 'securerandom'
require 'template-caddy'
require "anbt-sql-formatter/formatter"

module DBO

	def self.connect type: 'greenshift', **details
		DBO::Database.new type: type, **details
	end

	class Database
		attr_reader   :type
		attr_accessor :default_schema, :default_database

		def initialize type: 'redshift', **details
			@type = type.downcase
			@conn = nil                               # FIX

			case @type
			when 'redshift'
				@conn = DBO::Connection::Redshift.new
			when 'greenshift'
				@conn = DBO::Connection::Redshift.new
			else
				raise "Unknown database type."
			end

		end

		def default_database
			@conn.default_database
		end
	end

end


module DBO
	module Connection
		class Redshift
			require 'pg'
			include SQLCaddy

			attr_accessor :schema, :cursors, :active_schema, :default_database

			def initialize **args
				@schema = schema
				@cursors = []

				load_methods __dir__ + '/dbo/redshift/redshift.sql'  # Bad
				read_pgpass
				args = default_database if args.empty?
				@conn = PG.connect **args
			end

			def exec *args
				@conn.exec(*args).map { |row| row.values }
			end

			def read_pgpass
				target = ENV['HOME'] + '/.pgpass'
				@known_databases ||= []
				File.open(target).each do |line|
					line.chomp!
					next if line =~ /^\s*#/
					next unless line =~ /:/
					@known_databases << [
						:host, :port, :dbname, :user, :password
					].zip(line.split /:/).to_h
				end
				@known_databases.uniq!
				@default_database ||= @known_databases.first
			end

		end
	end
end


__END__


			def go_get template, *args
				ret  = []
				sql  = @sql[template]
				sql %= args unless args.empty?

				@conn.exec( sql ) do |result|
					result.each do |row|
						ret << row
					end
				end

				ret
			end


		end
	end
end
