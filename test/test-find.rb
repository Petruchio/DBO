$: << File.expand_path( File.dirname(__FILE__) + '/../src' )

require 'dbo'
require 'minitest/autorun'

class TestDBOFind < Minitest::Test

	def setup
		DBO.find_databases
		@t1 = DBO::Database.find { |db| db.name == 'template1' }
	end

	def test_find
		assert             DBO::Database.names.member?('template1')
		assert_kind_of     Array,         DBO::Database.names
		assert_kind_of     DBO::Database, @t1
		assert_equal       4,             DBO::Database.size
	end

end
