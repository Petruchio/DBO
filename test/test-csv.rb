require 'dbo/driver/csv'
require 'minitest/autorun'

class TestCSV < Minitest::Test

	def setup
		@debug = false
		@data_dir  = __dir__ + '/../data/'
		@malformed = @data_dir + '/malformed.csv'
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

	def test_defaults_and_creators
		csv = DBO::Driver::CSV.new('a,b,c', input_type: :string)
		assert_equal csv.encoding            , 'UTF-8'
		assert_equal csv.force_encoding      , true
		assert_equal csv.potential_delimiters, [',', "\t", ';']
		assert_equal csv.input_type          , :string
		assert_equal csv.quoted              , false

		DBO::Driver::CSV.default[:encoding]             = 'US-ASCII'
		DBO::Driver::CSV.default[:force_encoding]       = false
		DBO::Driver::CSV.default[:potential_delimiters] = %W(x y z)
		DBO::Driver::CSV.default[:input_type]           = 'string'
		DBO::Driver::CSV.default[:quoted]               = true

		csv2 = DBO::Driver::CSV.open __FILE__
		assert_equal 'US-ASCII', csv2.encoding
		assert_equal false     , csv2.force_encoding
		assert_equal %W(x y z) , csv2.potential_delimiters
		assert_equal 'file'    , csv2.input_type
		assert_equal true      , csv2.quoted
		DBO::Driver::CSV.restore_defaults

		jabb = get_awful_csv
		csv3 = DBO::Driver::CSV.parse jabb
		assert_equal  'UTF-8'         , csv3.encoding
		assert_equal  true            , csv3.force_encoding
		assert_equal  [',', "\t", ';'], csv3.potential_delimiters
		assert_equal  'string'        , csv3.input_type
		assert_equal  false           , csv3.quoted
	end

	def test_analyze_file
		# results = DBO::Driver::CSV.analyze_file(@malformed)
	end

	def test_csv
		csv = DBO::Driver::CSV.new('', input_type: :string)
		assert_kind_of Object,        csv
		assert_equal   true,          csv.force_encoding
		assert_equal   'UTF-8',       csv.encoding

		weird_file = []

		if @debug
			weird_file = DBO::Driver::CSV.parse_quoted_file(@malformed)
		else
			out, err = capture_io do
				weird_file = DBO::Driver::CSV.parse_quoted_file(@malformed)
			end
		end

		assert_match 'invalid byte sequence in UTF-8', err
#		assert_empty out

		_ = weird_file = out = err

	end

end

def get_awful_csv
	return <<-CSV
	’Twas brillig, and the slithy toves
				Did gyre and gimble in the wabe:
	All mimsy were the borogoves,
				And the mome raths outgrabe.

	“Beware the Jabberwock, my son!
				The jaws that bite, the claws that catch!
	Beware the Jubjub bird, and shun
				The frumious Bandersnatch!”

	He,took,his,vorpal,sword,in,hand;
	,,,,,,Long,time,the,manxome,foe,he,sought—
	So,rested,he,by,the,Tumtum,tree
	,,,,,,And,stood,awhile,in,thought.

	And, as in uffish thought he stood,
				The Jabberwock, with eyes of flame,
	Came whiffling, through the tulgey wood,
				And, burbled, as it came!

	One, two! One, two! And through and through
				The vorpal blade went snicker-snack!
	He left it dead, and with its head
				He went galumphing back.

	"And hast thou slain the Jabberwock?
				Come to my arms, my beamish boy!
	O frabjous day! Callooh! Callay!"
				He chortled in his joy.

	’Twas brillig, and the slithy toves
				Did gyre and gimble in the wabe:
	All mimsy were the borogoves,
				And the mome raths outgrabe.
	CSV
end
