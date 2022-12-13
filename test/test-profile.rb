require 'dbo/profile/parser'
require 'minitest/autorun'

Host  = DBO::Internal::Profile::Host
Match = DBO::Internal::Profile::Match

class TestProfileParser < Minitest::Test

	def setup
	end

	def test_host_class
		parts_1 = Host.split_host_list( 'foo bar,bat ,moo, boo ' )
		assert_equal 5,     parts_1.size
		assert_equal 'boo', parts_1.last
		parts_2 = Host.split_host_list( "\t\nfoo bar,bat ,\t  ,  , \nmoo,\t boo \t\n\t" )
		assert_equal parts_2, parts_1
	end

end
