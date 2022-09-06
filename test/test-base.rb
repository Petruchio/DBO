require 'dbo/base'
require 'minitest/autorun'

class TestBase < Minitest::Test

	def setup
		@base = DBO::Base.new
	end

	def test_paths
	end

end
