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

		attr_reader    :schemata,      :connection
		boolean_reader :datistemplate, :datallowconn
		int_reader     :datconnlimit,  :encoding, :datdba, :dattablespace, :datlastsysoid

		alias_method :schemas,      :schemata
		alias_method :template?,    :datistemplate
		alias_method :can_connect?, :datallowconn

		def initialize *args
			@sql = {}
			self.class.sql.each { |k,v| @sql[k] = v % [ args.first['datname'] ] }
			super *args
		end

		def name
			datname
		end

		def connect!
			return if     @connection.kind_of? PG::Connection
			@connection = PG.connect dbname: name
		end

		def disconnect!
			return unless @connection.kind_of? PG::Connection
			@connection.close
		end

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

		def schema_names
			@schemata.map { |s| s.name }
		end

		def self.display
			all.map { |db| db.display } * "\n"
		end

		def display
			"db: #{name}"
		end

	end
end
