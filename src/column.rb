module DBO
	class Column < Base

		def self.find(schema:, table:, connection:)
			ret = []

			sql = <<-END
				SELECT *
				FROM   information_schema.columns
				WHERE  table_schema = #{schema}
				AND    table_name   = #{table}
			END

			where = schema.nil? ? '' : "WHERE table_schema = '#{schema}'"
			connection.exec( "SELECT * FROM information_schema.columns #{where}" ) do |cols|

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
