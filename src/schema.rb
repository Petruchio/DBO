require 'pg'
require 'pp'
require 'dbo/table'

module DBO
	class Schema < Base

		attr_accessor :tables, :database

		def name
			@schema_name
		end

		def owner
			@schema_owner
		end

		def table_names
			@tables.map { |t| t.name }
		end

		def initialize( database: )
			@database = database
		end

		def self.find(conn)
			ret = []
			conn.exec( 'SELECT * FROM information_schema.schemata' ) do |schemata|
				schemata.fields.each { |f| attr_reader f.to_sym }
				schemata.each do |row|
					ret << this = self.new
					row.each { |k,v| this.instance_variable_set "@#{k}", v }
				end
			end
			ret
		end

		def analyze(conn)
			@tables = DBO::Table.find connection: conn, schema: name
			puts display
			@tables.each { |t| puts t.display }
		end

		def display
			"  |\n" +
			"  |--schema: #{name}\n" +
			"  |  \\"
		end
	end
end
