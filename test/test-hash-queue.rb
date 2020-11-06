require 'minitest/autorun'

$:.unshift '.'

require 'dbo/hash/queue'

class Hash                   # Figure out how to do this programmatically.
	include DBO::Hash::Queue
end

class TestHashQueue < Minitest::Test

	def setup
		puts "\nTesting DBO::Hash::Queue"
		@h = { a: 1, b: 2, c: 4, d: 8 }
	end

	def test_hash_queue
		assert_equal   4, @h.size
		assert         @h.more?
		assert_kind_of Array, h = @h.next
		assert_equal   :a, h.first
		assert         @h.more?

		assert_kind_of Array, h = @h.next
		assert_equal   :b, h.first
		assert_equal   1, @h.position

		assert_kind_of Array, (k, _ = *@h.next)
		assert_equal   :c, k

		assert_equal   :d, (k, _ = *@h.next).first
		refute         @h.more?
		@h.reset
		assert         @h.more?

		assert_equal   :a,  @h.next.first
		assert_equal   :b,  @h.next.first
		assert_equal   :c,  @h.next.first
		assert_equal   :d,  @h.next.first
		assert_nil     @h.next

		@h.backward!
		@h.reset
		assert_equal   :d,  @h.next.first
		assert_equal   :c,  @h.next.first
		assert_equal   :b,  @h.next.first
		@h.reverse!
		assert_equal   :c,  @h.next.first
		@h.reverse!
		assert_equal   :b,  @h.next.first

	end

end
