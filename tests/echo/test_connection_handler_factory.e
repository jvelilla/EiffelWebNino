note
	description: "Summary description for {TEST_CONNECTION_HANDLER_FACTORY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_CONNECTION_HANDLER_FACTORY

inherit
	HTTP_REQUEST_HANDLER_FACTORY

feature -- Factory

	new_handler: separate TEST_CONNECTION_HANDLER
		do
			create Result.make
			set_is_verbose (Result, False) -- FIXME
			if attached server as s then
				attach_controller_to_handler (Result, s)
			end
		end

	set_is_verbose (h: like new_handler; b: BOOLEAN)
		do
			h.set_is_verbose (b)
		end

	attach_controller_to_handler (h: like new_handler; a_server: attached like server)
		do
			h.set_controller (a_server.controller)
		end

feature -- Access

	server: detachable HTTP_SERVER

feature -- Change

	set_server (s: like server)
		do
			server := s
		end

end
