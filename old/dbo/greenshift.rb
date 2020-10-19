require 'pg'
require 'pp'
require 'securerandom'
require 'sql-caddy'
require "anbt-sql-formatter/formatter"

module DBO
	module Connection
		class Redshift

			attr_accessor :schema, :cursors, :active_schema

			def initialize schema: 'brighthouse_financial'
				@schema = schema
				@cursors = []
				@sql = TextCaddy.read __dir__ + '/redshift/redshift.sql'
				read_pgpass
				connect
			end

			def default_database
				@known_databases.first
			end

			def read_pgpass
				target = ENV['HOME'] + '/.pgpass'
				@known_databases ||= []
				File.open(target).each do |line|
					line.sub! /#.*/, ''
					next unless line =~ /:/
					@known_databases << [:host, :port, :dbname, :user, :password].zip(line.split /:/).to_h
				end
				@known_databases.uniq!
			end

			def exec *args
				@conn.exec(*args).map { |row| row.values }
			end

			def connect **args
				unless args.has_key? :database     # Should be handled better.
					args = default_database
				end
				@conn = PG.connect(
					host:     'modco.channelmix.com',
					port:     5439,
					user:     'modco_reporting',
					dbname:   'modco',
					password: 'm3%2B0R#It2l'
				)
			end

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
