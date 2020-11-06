require 'minitest/autorun'

$:.unshift '.'

require 'dbo/caddy/sql'
require 'dbo/connection/postgresql'

class TestSQLCaddy < Minitest::Test

	def setup
		puts "\nTesting DBO::Caddy::SQL"
		@s = DBO::Caddy::SQL.new __FILE__

		# This will break for others, but I haven't released this yet.
		@s.database = DBO::Connection::PostgreSQL.new dbname: 'brighthouse'
	end

	def test_rendering
		assert_kind_of String, @s.render(
			:where_string,
			table_name:   'my_table',
			column_name:  'my_table',
			match_column: 'my_table',
			value:        'my_value'
		)
		assert_equal   'SELECT * FROM foo', @s.render( :all, table_name: 'foo' ).strip
	end


	def test_connection
		assert_raises( RuntimeError ) { @s.use(:foo) }

		assert_kind_of    Array,  views = @s.use(
			:column, column_name: 'table_name', table_name: 'information_schema.views'
		)

		assert_kind_of    Hash, views.first
		assert_includes   views, {"table_name" => "views"}

#		pp @s.try_chain(
#			:tables,
#			:count,
#			table_schema: 'alight'
#		)
	end

end

__END__

---> all

SELECT * FROM %{table_name}

---> tables

SELECT table_schema, table_name FROM information_schema.tables
WHERE  table_schema = '%{table_schema}';

---> count

SELECT
	'%{table_schema}' AS table_schema,
	'%{table_name}'   AS table_name,
	count(*)
FROM %{table_schema}.%{table_name}

---> column

SELECT %{column_name} FROM %{table_name}

---> columns

SELECT %{column_1}, %{column_2} FROM %{table_name}

---> where_string

SELECT %{column_name} FROM %{table_name}  
	WHERE %{match_column} = '%{value}'  

---> natural_join

SELECT * FROM %{table_1} NATURAL JOIN %{table_2}
