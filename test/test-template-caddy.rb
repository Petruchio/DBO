require 'minitest/autorun'

$:.unshift '.'

require 'dbo/caddy/template'

class TestDBO < Minitest::Test
	def setup
		puts "\nTesting DBO::Caddy::Template"
		@s = DBO::Caddy::Template.new __FILE__
		@s.default = :where_string
	end
	def test_caddy
		assert_match 'SELECT * FROM my_table', @s.render(:all, table: 'my_table')
		assert_match 'SELECT * FROM t1 NATURAL JOIN t2', @s.render(:natural_join, table_1: 't1', table_2: 't2')
		assert_match @s.render(:all, table: 'my_table'), @s.r(:all, table: 'my_table')
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
