module DBO
	class Table < Base

		attr_accessor :database, :schema, :type, :insertable

		alias_method  :is_insertable?, :insertable

		def initialize *args
			arg        = args.first
			@name      = arg['table_name']
			@type      = arg['table_type']
			@database  = Database[ arg['table_catalog' ] ]
			@schema    = Schema[   arg['table_schema'  ] ]
			@inserable = arg['is_insertable_into']       == 'YES'
			@type      = arg['table_type']
			@sql  = {}
			self.class.sql.each { |k,v| @sql[k] = v % [ @name ] }
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

	end
end
