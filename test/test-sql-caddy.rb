require 'minitest/autorun'

$:.unshift '.'

require 'dbo/caddy/sql'

class TestSQLCaddy < Minitest::Test
	def setup
		puts "\nTesting DBO::Caddy::SQL"
		@s = DBO::Caddy::SQL.new __FILE__
	end
	def test_caddy
		assert_kind_of String, @s.render(
			:where_string,
			table: 'my_table',
			field: 'my_field',
			value: 'my_value'
		)
	end

end

__END__

---> all

SELECT * FROM %{table}

---> where_string

SELECT * FROM %{table}  
	WHERE %{field} = '%{value}'  

---> natural_join

SELECT * FROM %{table_1} NATURAL JOIN %{table_2}

---> count

SELECT count(*) FROM %{table}
