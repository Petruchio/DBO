require 'securerandom'
require 'dbo/sql/caddy'
require "anbt-sql-formatter/formatter"

module DBO

	def self.connect type:, **details
		case type
		when 'redshift'
			return DBO::Connection::Redshift.new **details
		else
			raise "No driver found for #{type}."
		end
	end


	module Connection

		SQL_FILE = {
			Redshift: __dir__ + '/sql/redshift.sql'
		}

		def sql_file
			key = self.class.name.split('::').last.to_sym
			SQL_FILE[key]
		end

		class Redshift
			include DBO::Connection
			require 'pg'

			attr_accessor :active_schema, :default_database, :active_database

			def initialize **args
				@caddy = TemplateCaddy.new sql_file
				@active_schema = args[:schema]
				@cursors = []
				read_pgpass
				args = default_database if args.empty?
				@active_database = args[:database]
				@conn = PG.connect **args
			end

			def read_pgpass
				target = ENV['PGPASSFILE'] || ENV['HOME'] + '/.pgpass'
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

			def sql_methods
				@caddy.keys
			end

			def tables
				exec @caddy.tables
			end

			def databases
				get(:databases).map { |db|
					Database.new connection: @conn, **db
				}
			end

			def database_names
				get(:database_names).map { |h| h.values }.flatten
			end

			private

				def get template
					@conn.exec(@caddy.send template).to_a
				end

				def go_get template, *args
					ret  = []
					sql  = @caddy[template]
					sql %= args unless args.empty?

					@conn.exec( sql ) do |result|
						result.each do |row|
							ret << row
						end
					end

					ret
				end

				def exec *args
					@conn.exec(*args).map { |row| row.values }
				end

		end


	end

	class Database

		attr_accessor :default_schema, :name

		def initialize connection:, **others
			@connection = connection
			@name = others['datname']
			@attribute = others.transform_keys {|key| key.to_s }
		end

		def method_missing name, **args
			super name, **args
		end

		def to_s
			super.sub /:\w+>/, ":#{@name}>"
		end

	end


end

__END__


		def default_database
			@conn.default_database
		end
	end

end


module DBO
	module Connection
		class Redshift
			require 'pg'

			attr_accessor :schema, :cursors, :active_schema, :default_database

			def exec *args
				@conn.exec(*args).map { |row| row.values }
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
