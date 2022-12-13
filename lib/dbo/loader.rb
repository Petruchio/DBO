require 'ruby-filemagic'

def bar
	puts '*' * 80
end

module DBO
	class Loader
		class << self

			def file_details filename
				filename = filename.to_s
				ret = {}

				# Not quite sure about the arguments to FileMagic.open;
				# the documentation is pretty poor.  Right now, :mime
				# is good enough.

				FileMagic.open(:mime) do |fm|
					results = fm.file(filename)
					return nil unless results
					type, encoding = results.split(/;\s*/)
					ret = { type: type, encoding: encoding }
				end
				ret
			end

			def file_encoding filename
				details = file_details filename
				return nil unless details
				details[:encoding].sub(/charset=/, '')
			end

			def file_type     filename
				details = file_details filename
				return nil unless details
				details[:type]
			end

		end
	end
end
