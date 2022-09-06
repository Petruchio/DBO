# These should be in the DBO namespace.

def die message = false
	if message
		warn message
	end
	exit 1
end

