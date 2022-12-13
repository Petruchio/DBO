module Sequel
	class Dataset
	end
end

module DBO

	refine Class do
		def default_element
			:div
		end
	end

	refine Object do
		def to_html element = default_element
			return "<#{element}>#{self.to_s}</#{element}>"
		end
	end


	refine Enumerable do
		def default_element
			:ul
		end

		def default_child_element
			:li
		end

		def to_html(
			element = default_element,
			child_element: default_child_element
		)
			out = map { |x| x.to_html(child_element) } * "\n"
			return "<#{element}>\n#{out}\n</#{element}>"
		end
	end

	refine Sequel::Dataset do
		def default_element
			:table
		end

		def child_element
			:tr
		end

		def to_html element = default_element
			out  = first.keys.map do |k|
				format_th(k)
			end.to_html( :tr, child_element: :th )
			out += map do |x|
				x.values.to_html( :tr, child_element: :td )
			end * "\n"
			"\n#{out}\n".to_html(element)
		end

		private

			def format_th symbol
				ret = symbol.to_s.split(/_/).map { |w| w.capitalize }
				ret.each_with_index do |v,i|
					ret[i] = 'ID' if v == 'Id'
					ret[i] = 'to' if v == 'To'
					# More rules here.
				end
				ret * ' '
			end
	end

end
