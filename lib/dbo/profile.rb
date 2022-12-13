require 'yaml'
require 'symbolize_keys_recursively'
require 'dbo/utility'
require 'sequel'
require 'cgi'
require 'dbo/profile/parser'

module DBO
	class Profile

		@@url_template = '%<adapter>s://%<user>s:%<password>s@%<host>s/%<database>s'

		@@necessary_keys = [
			:adapter, :user, :password, :host, :database, :port
		]

		attr_accessor :warnings

		def initialize warnings: true
			@current = nil
			@warnings = warnings
			@config_file   = ENV['DBO_PROFILES']
			@config_file ||= ENV['HOME'] + '/.dbo-profiles'
			load_config
		end

		def profiles
			@config.keys
		end

		def [] profile
			@config[:default].merge @config[profile.to_sym]
		end

		def url profile
			unless profiles.include? profile.to_sym # Warning:  not checking for file changes.
				raise "Unknown profile: #{profile}"
			end
			prof = self[profile]
			args = prof.map { |k,v| [k, CGI.escape(v.to_s)] }.to_h
			@current = @@url_template % args
			@current.gsub(/\+/, '%20')    # Shouldn't be necessary... but it is.  Find out why.
		end

		def connect profile
			db_url = url(profile)
			puts db_url
			Sequel.connect db_url
		end

		private

			# TODO:  Add checks to this:

			def load_config
				@config = YAML.load_file @config_file
				@config.symbolize_keys_recursively!
			end

			# Broken:

			def missing_keys
				necessary_keys - profile.keys
			end

			#-- Stolen from net/ssh/config.rb

			def parse_lines text
				ret = {}

				text.each do |line|
					next if line =~ /^\s*(?:#.*)?$/
					if line =~ /^\s*(\S+)\s*=(.*)$/
						key, value = $1, $2
					else
						key, value = line.strip.split(/\s+/, 2)
					end

					next if value.nil?

					key.downcase!
					value = unquote value

				end
				ret
			end

			def unquote string
				string =~ /^"(.*)"$/ ? Regexp.last_match(1) : string
			end


=begin
		unless @config.has_key? profile
			die "Unknown profile: #{profile}"
		end

		profile = config[:default].merge config[profile]
=end

	end
end
