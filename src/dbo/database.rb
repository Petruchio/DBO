lib = File.expand_path( File.dirname(__FILE__) + '/../../src' )
$:.unshift(lib) unless $:.include?(lib)

require 'dbo/base'

module DBO
	class Database < Base

		@schemata  = {}

		@sql = {
			schemata:  <<-END
				SELECT *
				FROM   information_schema.schemata
				WHERE  catalog_name = '%s'
			END
		}

		attr_reader :schemata,
		            :connection,
		            :name,
		            :is_template,
		            :can_connect,
		            :connection_limit,
		            :encoding

		alias_method :schemas,      :schemata
		alias_method :template?,    :is_template
		alias_method :can_connect?, :can_connect

		def initialize *args
			arg               = args.first
			@name             = arg['datname']
			@is_template      = arg['datistemplate'] == 't'
			@can_connect      = arg['datallowconn' ]  == 't'
			@connection_limit = arg['datconnlimit' ].to_i
			@datdba           = arg['datdba'       ].to_i
			@encoding         = arg['encoding'     ].to_i
			@dattablespace    = arg['dattablespace'].to_i
			@datlastsysoid    = arg['datlastsysoid'].to_i
			@sql  = {}
			self.class.sql.each { |k,v| @sql[k] = v % [ args.first['datname'] ] }
			super *args
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
			db.connect!
			db.connection.exec( @sql[:schemata] ) do |sch|
				Schema.new_attr_reader *sch.fields
				sch.each do |row|
					ident = "%s::%s" % row.values_at( 'catalog_name', 'schema_name' )
					next if Schema.map { |s| s.ident }.include?  ident
					Schema.new row
				end
			end
			db.disconnect!
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

	end
end
