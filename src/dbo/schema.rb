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

		def ident
			"#{catalog_name}::#{name}"
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
