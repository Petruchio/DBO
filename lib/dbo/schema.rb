module DBO
	class Schema < Base

		attr_accessor :name, :owner, :tables, :database

		@sql = {
			tables:  <<-END
				SELECT *
				FROM   information_schema.tables
				WHERE  table_schema = '%s'
			END
		}

		def initialize **args
			@owner = schema_owner
			@sql  = {}
			self.class.get_sql name: name
			super **args
		end

		def find_tables
disable = <<END
			return unless can_connect?
			connect!
			@connection.exec( @sql[:schemata] ) do |sch|
				Schema.new_attr_reader *sch.fields
				sch.each do |row|
					ident = "%s::%s" % row.values_at( 'catalog_name', 'schema_name' )
					next if Schema.map { |s| s.ident }.include?  ident
					Schema.new row
				end
			end
END
		end

		def table_names
			@tables.map { |t| t.name }
		end

		def ident
			"#{catalog_name}::#{name}"
		end

		def analyze(conn)
			@tables = DBO::Table.find connection: conn, schema: name
			puts display
			@tables.each { |t| puts t.display }
		end

	end
end
