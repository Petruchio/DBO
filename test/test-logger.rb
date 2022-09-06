require 'dbo/logger'
require 'minitest/autorun'

class TestLogger < Minitest::Test

	def setup
		@logger = DBO::Logger.new
	end

	def test_methods
		refute @logger.debug
		assert_output('')      { @logger.log 'foo' }
		@logger.level = 1
		assert @logger.debug
		assert_output("foo\n") { @logger.log 'foo' }
	end

end
