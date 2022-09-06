require 'dbo/profile'
require 'minitest/autorun'

class TestProfile < Minitest::Test

	def setup
	end

	def test_class
		assert_kind_of Array, DBO::Profile.sources
		assert_equal DBO::Profile.sources.first, ENV['HOME'] + '/.db-profiles'
		DBO::Profile.sources << 'nuts'
		assert_equal 'nuts', DBO::Profile.sources.last
		DBO::Profile.set_sources __dir__ + '/etc/db-profiles'
		assert_equal 1, DBO::Profile.sources.size
		snazz = DBO::Profile[:snazzy]
		assert_kind_of DBO::Profile, snazz
		assert_equal 'alphonso',     snazz[:user]
		assert_equal 'snazzy_stuff', snazz[:database]
	end

end
