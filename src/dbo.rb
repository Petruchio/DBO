$: << File.expand_path( File.dirname(__FILE__) + '/' )

require 'pg'
require 'pp'

require 'dbo/base'
require 'dbo/column'
require 'dbo/database'
require 'dbo/schema'
require 'dbo/table'



module DBO

	@sql = {
		databases: 'SELECT * FROM pg_database',
		schemata:  'SELECT * FROM information_schema.schemata',
		tables:    'SELECT * FROM information_schema.tables',
		columns:   'SELECT * FROM information_schema.columns',
	}



	def self.find_databases
		conn = PG.connect dbname: 'template1'
		conn.exec( @sql[:databases] ) do |db|
			Database.new_attr_reader *db.fields
			db.each do |row|
				next if Database.names.member? row['datname']
				Database.new( row )
			end
		end
		conn.close
	end



	def self.find_schemata(dbase)
		db = dbase.kind_of?(DBO::Database) ? dbase : DBO::Database[dbase]
		return unless db.can_connect?
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

	def self.find_tables
	end

	def self.find_columns
	end

	def self.find
		self.find_databases
		DBO::Database.each do |db|
			self.find_schemata db
		end
	end

end
