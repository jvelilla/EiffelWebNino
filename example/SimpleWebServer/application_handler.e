note
	description: "Summary description for {APPLICATION_HANDLER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	APPLICATION_HANDLER

inherit
	HTTP_HANDLER

create
	make

feature {NONE} -- Initialization

	build_pool (n: INTEGER)
		do
			create {separate APPLICATION_CONNECTION_POOL} pool.make (n)
			initialize_pool (pool, n)
		end

feature {NONE} -- Factory

	new_http_connection_handler: separate HTTP_CONNECTION_HANDLER
		local
			h: separate APPLICATION_CONNECTION_HANDLER --| Remove "separate" to get non concurrent behavior
		do
			create h.make (is_verbose)
			Result := h
		end

note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
