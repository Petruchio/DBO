require 'minitest/autorun'

$:.unshift '.'

require 'dbo/caddy/pgpass'

class TestPostgreSQL < Minitest::Test
	def setup
		puts "\nTesting DBO::Caddy::PGPass"
		@pg1 = DBO::Caddy::PGPass.new
		@pg2 = DBO::Caddy::PGPass.new __FILE__
	end
	def test_postgresql_driver
		assert_kind_of DBO::Caddy::PGPass, @pg1
		assert_kind_of Hash, @pg1[:Modco]
		assert_kind_of Hash, @pg2['A_User@A_Host:A_Database']
		assert_kind_of Hash, @pg2[:A_User]
		assert_kind_of Hash, @pg2[:A_Database]
		assert_equal   1234, @pg2['A_User'][:port]
	end
end

__END__

A_Host:1234:A_Database:A_User:A_Password

The_Host:1234:The_Database:The_User:The_Password
