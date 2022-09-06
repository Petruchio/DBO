$: << File.expand_path( File.dirname(__FILE__) + '/../src' )

require 'dbo/sql'
require 'minitest/autorun'

module DBO
	class TestSQL < Minitest::Test

		def setup
			@sql = []
			@sql << ( SQL | "SELECT * FROM '%{foo}'" )
			@sql << SQL[  "SELECT %{bar}  FROM '%{foo}'" ]
		end

		def test_methods

			assert_kind_of   SQL,                      @sql.first
			assert_kind_of   DBO::SQL,                 @sql.first
			assert_equal     "SELECT * FROM '%{foo}'", @sql.first
			assert_equal     "SELECT * FROM 'bucket'", (@sql.first % { foo: 'bucket' } )

		end

	end

end
