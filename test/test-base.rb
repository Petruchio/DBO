$: << File.expand_path( File.dirname(__FILE__) + '/../src' )

require 'dbo/base'
require 'minitest/autorun'

class TestDBOBase < Minitest::Test

	def setup
		DBO::find_databases
		@db = DBO::Database.first
		@db.instance_variable_set('@test_bool', 't')
		@db.instance_variable_set('@test_int',  '2')
		DBO::Base.boolean_reader :test_bool, :other_bool
		DBO::Base.int_reader     :test_int, 'other_int'
	end

	def test_base
		assert_kind_of     Array,  DBO::Base.all
		assert_operator    2, :<=, DBO::Base.size

		DBO::Base.new_attr_reader 'a', 'b', :c

		assert_respond_to  @db, :a
		assert_respond_to  @db, :c

		assert_kind_of     DBO::Base,      DBO::Base.first
		refute_equal       DBO::Base.last, DBO::Base.first
		assert_respond_to  DBO::Base,      :slice
		assert_equal       @db.test_bool,  true
		assert_equal       2,              @db.test_int
		assert_equal       0,              DBO::Database.last.test_int
		assert_respond_to  @db,            :other_int
		assert_respond_to  @db,            'other_bool'

		assert_equal       ({}),           DBO::Base.sql
	end

end
