# This is basically working.

require 'dbo/utility'

# TODO:  Add delegation.  Calling values.values sucks.

module DBO
	class Template

		@path = [ __dir__ ] # Default

		class << self

# Should check to see that a new path is actually valid,
# but for now it's easier to use simple attr_accessors.

			attr_accessor :path

			def find template
				file = template.to_s
				ret  = false

				if File.absolute_path? file
					ret = file
				else
					path.each do |dir|
						candidate = "#{dir}/#{file}"
						ret = File.absolute_path(candidate) if File.exist? candidate
					end

					unless ret && (file =~ /\.sql$/)
						path.each do |dir|
							candidate = "#{dir}/#{file}.sql"
							ret = File.absolute_path(candidate) if File.exist? candidate
						end
					end
				end

				# Mayhap these should raise errors, rather than return false.
				# Think it over.

				unless ret
					warn "Template not found: #{file}"
					return false
				end

				unless File.readable? ret
					warn "Template is not readable: #{ret}"
					return false
				end

				if File.directory? ret
					warn "#{ret} is a directory, not a regular file."
					return false
				end

				unless File.file? ret
					warn "Template is not a regular file: #{ret}"
					return false
				end

				ret
			end

		end

		attr_accessor :path, :values

		def initialize file = false
			@path = self.class.path
			@values = {}
			return unless file
			load file
		end

		def load template
			target = self.class.find template
			die unless target
			file = File.open target
			ret  = {}
			key  = false
			file.each do |l|
				if l =~ /^--->\s+((?:\w|-)+):\s*$/
					key      = $1.to_sym
					ret[key] = ''
					next
				end
				next unless key
				ret[key] += l
			end
			@values = ret
			ret
		end

	end
end
