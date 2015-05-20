$: << File.expand_path( File.dirname(__FILE__) + '/' )

require 'pg'
require 'pp'

require 'dbo/base'
require 'dbo/column'
require 'dbo/database'
require 'dbo/schema'
require 'dbo/table'



module DBO

	@sql = { databases: 'SELECT * FROM pg_database' }


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

end
