$: << __dir__ unless $:.include? __dir__

require 'pg'

#require 'dbo/base'
#require 'dbo/database'
#require 'dbo/schema'
#require 'dbo/table'
#require 'dbo/column'
#require 'dbo/template'
#require 'dbo/utility'

module DBO
	def path
		__dir__
	end
	module_function :path
end
