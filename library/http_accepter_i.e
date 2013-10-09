note
	description: "Summary description for {HTTP_ACCEPTER_I}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	HTTP_ACCEPTER_I

inherit
	HTTP_DEBUG_LOGGER

feature {NONE} -- Initialization

	frozen make (a_server: like server) --; a_handler: like handler)
		do
			server := a_server
--			handler := a_handler
			controller := separate_controller (a_server)
			factory := separate_factory (a_server)
			initialize
		end

	initialize
		deferred
		end

	factory: separate HTTP_CONNECTION_HANDLER_FACTORY

	separate_factory (a_server: like server): like factory
		do
			Result := a_server.factory
		end


	controller: separate HTTP_CONTROLLER

	separate_controller (a_server: like server): like controller
		do
			Result := a_server.controller
		end

	server: separate HTTP_SERVER

feature {HTTP_LISTENER_I} -- Execution

	process_incoming_connection (a_socket: TCP_STREAM_SOCKET)
		deferred
		end

	shutdown
		deferred
		end

feature {HTTP_LISTENER_I} -- Status report

	wait_for_completion
			-- Wait until Current completed any pending task
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

feature -- Access

	is_shutdown_requested: BOOLEAN
		deferred
		end

note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
