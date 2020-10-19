require 'minitest/autorun'

require 'dbo/softhash'

class TestSoftHash < Minitest::Test
	def setup
		puts "\nTesting DBO::SoftHash"
		@s = { alpha:  2, bravo:  4, charlie:  8, delta:  16, duplicate:  32 }
		@h = { Alpha: -2, Bravo: -4, Charlie: -8, Delta: -16, Duplicate: -32 }
	end
	def test_soft_hash
		assert_kind_of     SoftHash, { a: 2, b: 4, c: 8 }.soft
		assert_kind_of     SoftHash, sh = @s.soft
		assert             sh.soft?
		assert_instance_of Hash, sh.to_h
		assert_equal       4, sh[:bravo]
		assert_equal       4, sh[:bra]
		assert_equal       8, sh['ChA']
		assert_nil         sh[:zoo]
		assert_raises      KeyError do
			sh[:d]
		end
		assert_kind_of     SoftHash, hh = @h.soft.hard!
		assert_kind_of     SoftHash, hh
		assert             hh.hard?
		refute             hh.soft?
		assert_equal(      -4, hh[:Bravo])
		assert_nil         hh[:Brav]
		assert_nil         hh[:bravo]
		assert_nil         hh['bravo']
		assert             hh.soft!
		assert             hh.soft?
		refute             hh.hard?
		assert_equal(      -8, hh['char'])
	end

end
