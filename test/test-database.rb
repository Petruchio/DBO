$: << File.expand_path( File.dirname(__FILE__) + '/../src' )

require 'dbo/database'
require 'minitest/autorun'

class TestDBODatabase < Minitest::Test

	def setup
		DBO.find_databases

		@base1 = DBO::Base.first
		@base1.instance_variable_set('@test_bool2', 't')

		@db1   = DBO::Database.first
		@db1.instance_variable_set(  '@test_bool2', 'f')
		@db1.instance_variable_set(  '@test_int2',  '3')

		@db2   = DBO::Database.last
		@db2.instance_variable_set(  '@test_bool2', 't')

		DBO::Database.boolean_reader   :test_bool2
		DBO::Database.int_reader       :test_int2

		DBO::Base.new_attr_reader     'd'
		DBO::Database.new_attr_reader 'e', :f

	end

	def test_database
		assert_kind_of     Array,     DBO::Database.all
		assert_equal       4,         DBO::Database.size


		assert_respond_to  DBO::Base.new, :d
		refute_respond_to  DBO::Base.new, :f
		assert_respond_to  @db1,   :d
		assert_respond_to  @db1,   :f

		assert_kind_of     DBO::Base,          DBO::Database.first
		assert_kind_of     DBO::Database,      DBO::Database.first
		refute_equal       DBO::Database.last, DBO::Database.first
		assert_respond_to  DBO::Base,          :slice
		refute_respond_to  DBO::Base,          :test_bool2
		assert_equal       false,              @db1.test_bool2
		assert_equal       true,               @db2.test_bool2
		refute_respond_to  DBO::Base,          :test_int2
		assert_equal       3,                  @db1.test_int2
		assert_equal       0,                  @db2.test_int2
	end

end
