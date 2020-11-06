module DBO
	module Hash
		module Queue

			def orientation
				@orientation ||= :forward
			end

			def forward!
				@orientation   = :forward
			end

			def forward?
				orientation  == :forward
			end

			def backward!
				@orientation   = :backward
			end

			def backward?
				orientation  == :backward
			end

			def reverse!
				forward? ? backward! : forward!
			end

			def reset
				@position = forward? ? -1 : size
			end

			def position
				defined?(@position) ? @position : reset
			end

			def increment_position
				return position if position >= size
				@position += 1
			end

			def decrement_position
				return position if position <= 0
				@position -= 1
			end

			def step
				forward? ? increment_position : decrement_position
			end

			def current
				slice(keys[position]).to_a.first
			end

			def next
				step
				current
			end

			def more?
				position < size - 1
			end

		end
	end
end
