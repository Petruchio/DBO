require 'yaml'
require 'symbolize_keys_recursively'
require 'dbo/utility'
require 'json'

# NB: Composing everything with chains of short method calls is cute,
# but this code is really inefficient.  Should refactor.
#
# Also, the distribution of responsibilities between the class and the
# instances needs to be considered more closely.  For now, it works though.

module DBO
	class Profile

		@sources = [ ENV['HOME'] + '/.db-profiles' ] # Default

		class << self

			attr_reader :sources, :data

			def set_sources *list
				@sources = list
			end

			def load
				ret = {}
				sources.each do |f|
					ret.merge! YAML.load_file(f).symbolize_keys_recursively!
				end
				@data = ret
			end

			def default
				include?(:default) ? @data[:default] : {}
			end

			def list
				load.keys
			end

			def include? name
				list.include? name.to_sym
			end

			def all
				list.map { |profile|
					"Placeholder:  create #{profile}."
				}
			end

			def [] name
				self.new name
			end

		end


		attr_accessor :sources, :values

		def initialize name
			raise "Unknown profile: #{name}" unless self.class.include? name
			@values = self.class.load[name.to_sym].merge self.class.default
		end

		def [] key
			values[key]
		end

		def to_url
			url_template = '%<adapter>s://%<user>s:%<password>s@%<host>s/%<database>s'
			connect_url = url_template % @values
			connect_url.gsub(/ /, '%20')
		end

		def to_json
			JSON.generate @values
		end

	end
end
