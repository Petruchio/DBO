require 'tiny_tds'

module DBO
	module Connection
		class SQLServer


			def initialize username: ENV['USER'], password: , host: 'localhost', **options
				@conn = TinyTds::Client.new username: username, password: password, host: host, **options
			end

			def exec *args
				@conn.execute(*args).map { |r| r }
			end


		end
	end
end
