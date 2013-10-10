note
	description: "Summary description for {HTTP_CONNECTION_HANDLER_I}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	HTTP_CONNECTION_HANDLER_I

inherit
	HTTP_DEBUG_FACILITIES

feature {NONE} -- Initialization

	frozen make (a_server: like server)
		do
			server := a_server
			factory := separate_factory (a_server)
			initialize
		end

	initialize
		deferred
		end

	separate_factory (a_server: like server): like factory
		do
			Result := a_server.factory
		end

feature {NONE} -- Access

	factory: separate HTTP_REQUEST_HANDLER_FACTORY

	server: separate HTTP_SERVER

feature {HTTP_SERVER} -- Execution

	process_incoming_connection (a_socket: TCP_STREAM_SOCKET)
		deferred
		end

	shutdown
		deferred
		end

	wait_for_completion
			-- Wait until Current completed any pending task
		deferred
		end

feature {HTTP_SERVER} -- Status report

	is_shutdown_requested: BOOLEAN
		deferred
		end

feature {NONE} -- Output

	log (a_message: READABLE_STRING_8)
			-- Log `a_message'
		do
			server_log (a_message, server)
		end

	server_log (a_message: READABLE_STRING_8; a_server: like server)
		do
			a_server.log (a_message)
		end

note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
