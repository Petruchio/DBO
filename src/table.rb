require 'dbo/column'

module DBO
	class Table < Base

		def display
			"  |   |--table: #{name}\n"    +
			"  |   |  { type: #{type} }\n" +
			"  |   |"
		end

		def self.find(schema: nil, connection:)
			ret = []
			where = schema.nil? ? '' : "WHERE table_schema = '#{schema}'"
			connection.exec( "SELECT * FROM information_schema.tables #{where}" ) do |tables|

				tables.fields.each { |f| attr_reader f.to_sym }
				tables.fields.find_all { |t| t =~ /^table_/ }.each do |f|
					alias_method  f.sub(/table_/,'').to_sym, f.to_sym
				end
				alias_method :database, :catalog

				tables.each do |row|
					ret << this = self.new
					row.each { |k,v| this.instance_variable_set "@#{k}", v }
				end
			end
			ret
		end

		def analyze
#			DBO::Column.find schema:, table:, connection: connection
		end

	end
end
