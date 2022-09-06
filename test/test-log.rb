require 'dbo/log'
require 'minitest/autorun'

class TestLog < Minitest::Test

	include DBO::Log

	def setup
	end

	def test_methods
		assert_output('')          { log 'Message' }
		log_level 1
		assert_output("Message\n") { log 'Message' }
		debug :off
		assert_output('')          { log 'Message' }
		debug :on
		assert_output("Message\n") { log 'Message' }
		debug :toggle
		assert_output('')          { log 'Message' }
		debug :toggle
		assert_output("Message\n") { log 'Message' }
	end

end
