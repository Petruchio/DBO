$: << File.expand_path( File.dirname(__FILE__) + '/../src' )

require 'dbo'
require 'minitest/autorun'

module DBO
	class TestAll < Minitest::Test

		def setup
			Database.find_all
			Base.new_attr_reader     'a', :b
			Database.new_attr_reader :c

			@db = Database.first
			@t1 = Database['template1']
			@t1.find_schemata
			@s1 = Schema['information_schema']
			@s1.find_tables
		end

		def test_methods

			assert_respond_to  @db,      :a
			assert_respond_to  @db,      :c
			assert_respond_to  Base.new, :b
			refute_respond_to  Base.new, :c
			assert_respond_to  Base,     :slice

		end


		def test_classes

			assert_kind_of     Array,     Base.all
			assert_kind_of     Array,     Database.all
			assert_kind_of     Array,     Table.names
			assert_kind_of     Array,     Schema.names
			assert_kind_of     Base,      @db
			assert_kind_of     Database,  @db
			assert_kind_of     Schema,    Schema.first
			assert_kind_of     Schema,    @s1

		end

		def test_sizes

			assert_equal       4, Database.size
			assert_equal       3, Schema.size
			assert_operator    2, :<=, Base.size
			assert_equal       3, Table.size
			refute_equal       Database.last, Database.first
			refute_equal       Base.last,     Base.first

		end

		def test_misc

			assert_equal       ({}),      Base.sql
			assert             Schema.names.member?('information_schema')
			assert_kind_of     Schema, Schema.first

		end

	end

end
