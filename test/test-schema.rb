$: << File.expand_path( File.dirname(__FILE__) + '/../src' )

require 'dbo'
require 'minitest/autorun'

class TestDBOSchema < Minitest::Test

	def setup
		DBO.find_databases
		@t1 = DBO::Database['template1']
	end

	def test_find

		assert_kind_of     Array,         DBO::Database.names
		assert_equal       4,             DBO::Database.size
		assert_kind_of     DBO::Database, @t1

		assert             DBO::Database.names.member?('template1')


disable = <<END
END
	end

end
