require 'dbo'
require 'dbo/template'
require 'haml'

module DBO
	class Base

		def query *args
			self.connection.query( **args )
		end

		def self.view_path
			File.absolute_path( DBO.path + '/views' )
		end

		def name_to_path
			self.class.to_s.downcase.sub(/[^:]*::/, '').gsub(/::/, '/')
		end

		def sql_path
			DBO.path + '/sql/' + name_to_path + '.sql'
		end

		def html_path
			DBO.path + '/views/html/' + name_to_path + '.haml'
		end

		def text_path
			DBO.path + '/views/text/' + name_to_path + '.txt'
		end

		def load_sql
			@sql = Template.new(sql_path).values
		end

		def load_haml
			File.read html_path
		end

		def load_text
			File.read text_path
		end

		def as_html
			haml = load_haml
			Haml::Engine.new(haml).render(self)
		end

	end
end
