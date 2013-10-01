note
	description: "Summary description for {TEST_HTTP_CONNECTION_POOL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_HTTP_CONNECTION_POOL

inherit
	HTTP_CONNECTION_POOL

create
	make

feature -- Access

	new_connection_handler: separate HTTP_CONNECTION_HANDLER
		local
			h: separate TEST_CONNECTION_HANDLER --| Remove "separate" to get non concurrent behavior
		do
			create h.make (is_verbose)
			Result := h
		end

note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
