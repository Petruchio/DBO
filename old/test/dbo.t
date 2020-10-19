require 'minitest/autorun'
require 'pp'

$:.unshift '.'

require 'dbo'

class TestDBO < Minitest::Test

	def setup
		@dbo = DBO.connect type: 'redshift'
	end

	def test_dbo
		assert_kind_of DBO::Connection::Redshift, @dbo
		assert_kind_of Array,  @dbo.sql_methods
		assert_kind_of Array,  @dbo.database_names
puts @dbo.databases
#		assert_raises NoMethodError, @dbo.fizz
#		assert_equal 'redshift', @dbo.type
	end

end
