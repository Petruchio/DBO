require 'minitest/autorun'

$:.unshift '.'

require 'dbo/caddy/text'

class TestTextCaddy < Minitest::Test

	def setup
		puts "\nTesting DBO::Caddy::Text"
		$:.each do |dir|
			f = dir + 'dbo/caddy/text.rb'
			@mod = f if File.exist? f
		end
		raise "Couldn't find text-caddy.rb." unless @mod
	end

	def test_text_caddy
		assert_kind_of DBO::Caddy::Text, t1 = DBO::Caddy::Text.new(__FILE__)
		assert_kind_of(
			DBO::Caddy::Text,
			t2 = DBO::Caddy::Text.new(__FILE__, dense: true, strip: true)
		)
		t2.read "---> foo\nNuts\n #---> bar \n Nilbog "
		assert DBO::Caddy::Text.valid_file?( __FILE__ )
		refute DBO::Caddy::Text.valid_file?( @mod )
		assert_respond_to t1, :each
		assert_equal 4, t1.keys.size
		assert_equal 'Stuff stuff stuff.', t1[:thingy_1].strip
		assert_equal 'Stuff stuff stuff.', t2[:thingy_1]
		assert_match(/More stuff./, t1[:thingy_2])
		refute_equal 'More stuff.', t1[:thingy_2]
		assert_equal 'Nuts', t2[:foo]
		assert_equal 'Nilbog', t2[:bar]
		assert_nil   t2[:ba]
		t2.soft!
		assert_equal 'Nilbog', t2[:ba]

	end

end

__END__

---> thingy_1

Stuff stuff stuff.

---> thingy_2

More stuff.
Stuff.

Stuffedy-stuff.

---> thingy_3

Still more stuff.

	---> this that

---> thingy_4

I'm getting tired of all this stuff.

Boo.  ---> No more stuff.
