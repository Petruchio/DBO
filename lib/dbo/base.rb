require 'dbo'

module DBO
	class Base

		def query *args
			self.connection.query( **args )
		end

		def self.view_path
			File.absolute_path( DBO.path + '/views' )
		end

		def name_to_path
			ret = self.class.to_s.downcase.sub(/[^:]*::/, '').gsub(/::/, '/')
			File.absolute_path ret
		end

		def sql_path
			ret = DBO.path + '/sql/' + name_to_path + '.sql'
			File.absolute_path ret
		end

		def html_path
			ret = DBO.path + '/views/html/' + name_to_path + '.html'
			File.absolute_path ret
		end

		def text_path
			ret = DBO.path + '/views/text/' + name_to_path + '.html'
			File.absolute_path ret
		end

	end
end
