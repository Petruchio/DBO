require 'dbo/base'

module DBO
	class Database < Base

		attr_reader :schemata,
		            :connection,
		            :name,
		            :is_template,
		            :can_connect,
		            :connection_limit,
		            :encoding

		def initialize name:, connection:
			@connection = connection
			load_sql
			sql = @sql[:info] % { name: name }
			data = connection.query(sql).first

			@name             = name
			@is_template      = data[:datistemplate] == 't'
			@can_connect      = data[:datallowconn ] == 't'
			@connection_limit = data[:datconnlimit ].to_i
			@datdba           = data[:datdba       ].to_i
			@encoding         = data[:encoding     ].to_i
			@dattablespace    = data[:dattablespace].to_i
			@datlastsysoid    = data[:datlastsysoid].to_i
		end

		def schema_names
			sql = @sql[:schema_names] % { name: name }
			@connection.query( sql ).map { |row| row.values.first }
		end

		def to_str
			<<-END.gsub /\t/, ''
				****************************
				Hi, I'm a database!
				
				name:             #{@name}
				encoding:         #{@encoding}
				connection_limit: #{@connection_limit}
				datdba:           #{@datdba}
				****************************
			END
		end

	end
end


__END__

		@schemata  = {}

		@sql = {
			databases: 'SELECT * FROM pg_database',

			schemata:  <<-END
				SELECT *
				FROM   information_schema.schemata
				WHERE  catalog_name = '%{name}'
			END
		}

		alias_method :schemas,      :schemata
		alias_method :template?,    :is_template
		alias_method :can_connect?, :can_connect

		def initialize(
			datname:, datistemplate:, datallowconn:, datconnlimit:,
			datdba:, encoding:, dattablespace:, datlastsysoid:,
			**other
		)
			@sql  = self.class.get_sql name: datname
			other[:name] = datname
			super **other
		end

		# Connect to the database to which this database object corresponds..

		def connect!
			return if     @connection.kind_of? PG::Connection
			@connection = PG.connect dbname: name
		end

		# Disconnect from the database.

		def disconnect!
			return unless @connection.kind_of? PG::Connection
			@connection.close
		end

		# Find all schemata under this database, and create Schema objects for
		# them.

		def find_schemata
			return unless can_connect?
			connect!
			@connection.exec( @sql[:schemata] ) do |sch|
				Schema.new_attr_reader *sch.fields
				sch.each do |row|
					ident = "%s::%s" % row.values_at( 'catalog_name', 'schema_name' )
					next if Schema.map { |s| s.ident }.include?  ident
					row = row.symbolize_keys
					row[:name] = row[:schema_name]
					Schema.new **row
				end
			end
		end


	def self.find_all
		conn = PG.connect dbname: 'template1'
		conn.exec( @sql[:databases] ) do |db|
			Database.new_attr_reader *db.fields
			db.each do |row|
				next if Database.names.member? row['datname']
				row[:name] = row[:datname]
				Database.new **row.symbolize_keys
			end
		end
		conn.close
	end

		# List the names of all schemata within this database.
		# This may be different than the results of Schema.all, since
		# There may exist Schema objects for other datagbases.

		def schema_names
			@schemata.map { |s| s.name }
		end

		# Return strings which represent all databases.  This is an artifact of
		# the development process, and will probably be removed.

		def self.display
			all.map { |db| db.display } * "\n"
		end

		# Return a string which represents this database.  This is an artifact of
		# the development process, and will probably be removed.

		def display
			"db: #{name}"
		end

		def execute sql               # An optional block would be cool.
			return unless can_connect?
			connect!
			@connection.exec sql
		end

	end
end
