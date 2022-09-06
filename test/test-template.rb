require 'dbo/template'
require 'minitest/autorun'

class TestTemplate < Minitest::Test

	def setup
		@template_dir = __dir__ + '/templates/'
		DBO::Template.path << @template_dir
	end

	def test_paths

		# The new object is a template
		# The default path has only one directory
		# The object's path has only one directory

		@template_1  = DBO::Template.new
		assert_kind_of DBO::Template, @template_1
		assert_equal   2,             DBO::Template.path.size
		assert_equal   2,             @template_1.path.size


		# Add a non-existent directory to the default path.
		# Ideally, this would throw an error.

		DBO::Template.path << @template_dir + '/does-not-exist'


		# The new object is a template
		# The default path has two directories
		# The object's path has two directories

		@template_2  = DBO::Template.new
		assert_kind_of DBO::Template, @template_2
		assert_equal   3,             DBO::Template.path.size
		assert_equal   3,             @template_2.path.size


		# Can we find templates?
		assert_kind_of String, DBO::Template.find(:database)


		# Without an argument, a new DBO::Template should be empty.

		@t1 = DBO::Template.new
		assert_kind_of Hash,            @t1.values
		assert_equal   @t1.values.size, 0


		# See that a DBO::Template object can load a template

		@t1.load :database
		assert_equal   @t1.values.size, 2
		assert         @t1.values.has_key? :schemata


		# With an argument, a new DBO::Template should
		# load a template upon creation.

		@t2 = DBO::Template.new :test
		assert_equal   @t2.values.size, 3



#		assert_kind_of String, DBO::Template.find(:database)
#		assert_equal DBO::Template.find(:database), @template_dir + 'database'
	end

end
