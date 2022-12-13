require 'csv'
require 'stringio'
require 'dbo/utility'
require 'rchardet'

module DBO
	module Driver
		class CSV
			include DBO

			class << self

				def restore_defaults
					@default = {
						encoding:             'UTF-8',
						force_encoding:       true,
						potential_delimiters: %W( , \t ; ),
						input_type:           'file',
						quoted:               false,
					}
				end

				# Think through how to provide r/w access to
				# CSV.default[:whatever] without allowing
				# CSV.default to be overwritten
				# (or whether another approach is called for).

				attr_accessor :default

				def open(filename, **args)
					args[:input_type] = 'file'
					new(filename, **args)
				end

				def parse(string, **args)
					args[:input_type] = 'string'
					new(string, **args)
				end


				# Not yet using these next three functions.
				# Basically, though, the system needs to:
				#   * detect the probable character encoding
				#   * accept an alternate desired character encoding
				#   * identifying invalid characters, and:
				#     a. Report them
				#     b. Coerce them
				#     c. Elide them
				#
				# This is a big enough undertaking that this functionality
				# probably belongs in another (possibly stand-alone) package.


				def str_byte_length string
					string.unpack("C*").size
				end

				def detect_character_encoding string
					CharDet.detect string
				end

				def non_ascii_characters(string)
					ret = []
					string.each_byte { |x| ret << x if x > 127 }
					ret
				end


				# Mostly untested.  One additional feature to
				# implement is foreign character counting.  This,
				# like most naïve attempts to parse, presently breaks
				# on foreign characters.

				def analyze_file filename, lines: nil

					del_by_line = @default[:potential_delimiters].map { |d| [d, {}] }.to_h

					ret = {
						line_count:         0,
						longest_line:       0,
						delimiters_by_line: del_by_line,
						foreign_characters: []
					}

					line_limit = lines

					File.open(filename, 'r').each do |line|
						bad = non_ascii_characters(line)
						next if bad.empty?
						ret[:lines] ||= 1
						ret[:lines]  += 1
						len = line.length
						ret[:longest_line] = len if len > ret[:longest_line]

						del_by_line.keys.each do |d|
							occurances = line.split(d).size - 1
							ret[:delimiters_by_line][d][occurances] ||= 0
							ret[:delimiters_by_line][d][occurances] += 1
						end

						return ret if line_limit == ret[:lines]
					end

					return ret
				end



				def recognize? filename
					file = File.open filename, 'r'
					file.length
				end

				def seems_to_be_quoted? filename
				end

				def guess_delimiter filename
					file = File.open filename, 'r'
					file.length
				end

				def guess_field_count filename
				end

				def try_native_parse_file
				end

				# This is a method because it should
				# be made more sophisticated.

				def clean_encoding str
					str.scrub
				end

				def parse_quoted_file filename
					filename = File.absolute_path(filename)
					file     = File.open filename, 'r'
					open     = false
					records = []
					parts   = []
					file.each do |line|
						line = clean_encoding(line) if @force_encoding
						begin
							if line =~ /[^"]\s*$/
								open = false
							end
							parts << line
							unless open
								records << parts
								parts = []
							end
						rescue => e
							warn e
						end
					end
					records
				end

			end

			def skip_line
				skip_lines 1
			end

			def skip_lines n = 1
				n.times do
					@input.readline
				end
				nil
			end

			def next
				@input.readline
			end

			def each &block
			end

			restore_defaults
			attr_accessor :default, *@default.keys

			def initialize input, **arguments
				@default = self.class.default
				arg = @default.merge arguments
				keywords_to_vars(**arg)

				@input = nil
				case arg[:input_type].to_s.downcase
				when 'string'
					@input = StringIO.new( input )
				when 'file'
					@input = File.open( input, 'r' )
				else
					error = 'Unknown input_type: ' + arg[:input_type].to_s
					raise ArgumentError.new error
				end
			end

		end
	end
end
