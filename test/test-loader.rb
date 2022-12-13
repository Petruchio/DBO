require 'dbo/loader'
require 'minitest/autorun'

class TestLoader < Minitest::Test

	def setup
		@debug = false
		@data_dir = __dir__ + '/../data/'
	end


# If we want to clean this up, we can finish and use this:

	def do_this &block
		if @debug
			yield
			return [nil,nil]
		end

		capture_io do  # returns [out, err]
			yield
		end
	end


	def test_dbo_loader
		assert_kind_of Hash,          DBO::Loader.file_details(__FILE__)
		assert_equal   'text/x-ruby', DBO::Loader.file_type(__FILE__)
		assert_equal   'us-ascii',    DBO::Loader.file_encoding(__FILE__)
	end

end
