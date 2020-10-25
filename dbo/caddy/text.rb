require 'dbo/softhash'

module DBO
	module Caddy
		class Text < SoftHash

			attr_accessor :strip, :dense

			def self.valid_file? file
				f = new file
				! f.empty?
			end

			@@key_regex = %r{
				\s*
				(?:\#|//)*
				--->
				\s+
				((?:[-_@.:]|\w)+)
				\s*$
			}x

			def initialize *file, strip: false, dense: false, soft: false
				hard! unless soft
				@strip, @dense = strip, dense
				return if file.empty?
				file.each do |f|
					load f
				end
			end

			def load file
				read File.open(file)
			end

			def read source
				source = source.split("\n") if source.kind_of? String

				key = nil
				source.each do |line|
					if line =~ @@key_regex
						key = $1.to_sym
						store key, ''
						next
					end

					line.strip! if @strip
					next        if @dense && (line !~ /\S/)
					next        if key.nil?

					store key, self.values_at(key).first + line
				end

				self
			end

			def method_missing name, *args
				if @caddy.respond_to? name
					@caddy.send name, *args
				else
					super
				end
			end

			# N.B.  We offer some methods for cleaning up strings, here,
			# but they're poorly considered.  Improve this.

			def strip!
				each_value do |v|
					v.each_line { |l| l.strip! }
				end
			end

		end
	end
end
