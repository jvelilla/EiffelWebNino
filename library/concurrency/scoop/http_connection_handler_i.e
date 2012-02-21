note
	description : "Concurrent specific feature to implemente HTTP_CONNECTION_HANDLER"
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

deferred class
	HTTP_CONNECTION_HANDLER_I

feature {NONE} -- Initialization

	make (a_is_verbose: BOOLEAN)
		do
		end

feature -- Execution

	launch
		do
			execute
		end

	execute
		deferred
		end

note
	copyright: "2011-2011, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
