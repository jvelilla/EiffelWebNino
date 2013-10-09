note
	description: "[
			Instance of  HTTP_HANDLER_I

		]"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	HTTP_LISTENER_I

inherit
	HTTP_CONSTANTS

	HTTP_DEBUG_LOGGER

feature {NONE} -- Initialization

	make (a_server: like server)
			-- Creates a {HTTP_HANDLER}, assigns the server and initialize various values
			--
			-- `a_server': The main server object
		require
			a_server_attached: a_server /= Void
		do
			server := a_server
			is_shutdown_requested := False
			controller := controller_from_server (a_server)
			factory := factory_from_server (a_server)
			import_configuration (a_server.configuration)
			initialize
		ensure
			server_set: a_server ~ server
		end

	initialize
		do
			build_engine
		end

	build_engine
		deferred
		end

feature -- Access: Configuration

	is_verbose: BOOLEAN
			-- Is verbose for output messages.

	force_single_threaded: BOOLEAN

	http_server_name: detachable READABLE_STRING_8

	http_server_port: INTEGER

	max_tcp_clients: INTEGER

	max_concurrent_connections: INTEGER

	socket_connect_timeout: INTEGER

	socket_accept_timeout: INTEGER

feature -- Access

	port: INTEGER
			-- Listening port.
			--| 0: not launched

feature -- Status

	is_terminated: BOOLEAN
			-- Is terminated?

	is_shutdown_requested: BOOLEAN
			-- Set true to stop accept loop

	is_launched: BOOLEAN
			-- Server launched and listening on `port'	

feature {NONE} -- Access: server

	request_counter: INTEGER
			-- request counter, incremented for each new incoming connection.			

	server: HTTP_SERVER
			-- The main server object

	controller: separate HTTP_CONTROLLER

	engine: HTTP_ACCEPTER_I

feature -- Access

	factory: separate HTTP_CONNECTION_HANDLER_FACTORY

feature {NONE} -- Helpers

	factory_from_server (a_server: like server): like factory
		do
			Result := a_server.factory
		end

	controller_from_server (a_server: like server): like controller
		do
			Result := a_server.controller
		end

	server_log (a_message: READABLE_STRING_8; a_server: like server)
		do
			a_server.log (a_message)
		end

	shutdown_requested (a_controller: like controller): BOOLEAN
		do
			-- FIXME: we should probably remove this possibility, check with EWF if this is needed.
			Result := a_controller.shutdown_requested
		end

feature -- Execution

	execute
			-- <Precursor>
			-- Creates a socket and connects to the http server.
		local
			l_listening_socket,
			l_accepted_socket: detachable TCP_STREAM_SOCKET
			l_http_port: INTEGER
		do
			is_terminated := False
			is_launched := False
			port := 0
			is_shutdown_requested := False
			l_http_port := http_server_port
			if
				attached http_server_name as l_servername and then
				attached (create {INET_ADDRESS_FACTORY}).create_from_name (l_servername) as l_addr
			then
				create l_listening_socket.make_server_by_address_and_port (l_addr, l_http_port)
			else
				create l_listening_socket.make_server_by_port (l_http_port)
			end

			if not l_listening_socket.is_bound then
				if is_verbose then
					log ("Socket could not be bound on port " + l_http_port.out)
				end
			else
				l_http_port := l_listening_socket.port
				from
--					l_listening_socket.set_connect_timeout (socket_connect_timeout)
--					l_listening_socket.set_accept_timeout (socket_accept_timeout)
					l_listening_socket.listen (max_tcp_clients)
					if is_verbose then
						log ("%NHTTP Connection Server ready on port " + l_http_port.out +" : http://localhost:" + l_http_port.out + "/")
					end
					on_launched (l_http_port)
				until
					is_shutdown_requested
				loop
					l_listening_socket.accept
					if not is_shutdown_requested then
						l_accepted_socket := l_listening_socket.accepted
						if l_accepted_socket /= Void then
--							l_accepted_socket.set_timeout (0)
							request_counter := request_counter + 1
							if is_verbose then
								log ("#" + request_counter.out + "# Incoming connection...(socket:" + l_accepted_socket.descriptor.out + ")")
							end
							debug ("dbglog")
								dbglog (generator + ".before process_incoming_connection {" + l_accepted_socket.descriptor.out + "}" )
							end
							process_incoming_connection (l_accepted_socket)
							debug ("dbglog")
								dbglog (generator + ".after process_incoming_connection {" + l_accepted_socket.descriptor.out + "}")
							end
						end
					end
					update_is_shutdown_requested
				end
				wait_for_engine_completion (engine)
				l_listening_socket.cleanup
				check
					socket_is_closed: l_listening_socket.is_closed
				end
			end
			if is_launched then
				on_stopped
			end
			if is_verbose then
				log ("HTTP Connection Server ends.")
			end
		rescue
			log ("HTTP Connection Server shutdown due to exception. Please relaunch manually.")

			if l_listening_socket /= Void then
				l_listening_socket.cleanup
				check
					listening_socket_is_closed: l_listening_socket.is_closed
				end
			end
			if is_launched then
				on_stopped
			end
			is_shutdown_requested := True
			retry
		end

feature {NONE} -- Operation

	wait_for_engine_completion (e: like engine)
		do
			e.wait_for_completion
			debug ("dbglog")
				dbglog ("Shutdown ready from engine point of view")
			end
		end

	process_incoming_connection (a_socket: TCP_STREAM_SOCKET)
		do
			engine.process_incoming_connection (a_socket)
		end

	update_is_shutdown_requested
		do
			is_shutdown_requested := is_shutdown_requested or shutdown_requested (controller)
			if is_shutdown_requested then
				engine_shutdown (engine)
			end
		end

	engine_shutdown (e: like engine)
		do
			e.shutdown
		end

feature -- Event

	on_launched (a_port: INTEGER)
			-- Server launched using port `a_port'
		require
			not_launched: not is_launched
		do
			is_launched := True
			port := a_port
		ensure
			is_launched: is_launched
		end

	on_stopped
			-- Server stopped
		require
			is_launched: is_launched
		do
			is_launched := False
			is_terminated := True
		ensure
			stopped: not is_launched
		end

feature -- Output

	log (a_message: READABLE_STRING_8)
			-- Log `a_message'
		do
			server_log (a_message, server)
		end

feature {NONE} -- Configuration: initialization

	import_configuration (cfg: HTTP_SERVER_CONFIGURATION)
		do
			is_verbose := cfg.is_verbose
			force_single_threaded := cfg.force_single_threaded
			if attached cfg.http_server_name as l_http_server_name then
				create {IMMUTABLE_STRING_8} http_server_name.make_from_separate (l_http_server_name)
			else
				http_server_name := Void
			end
			http_server_port := cfg.http_server_port
			max_tcp_clients := cfg.max_tcp_clients
			max_concurrent_connections := cfg.max_concurrent_connections
			socket_connect_timeout := cfg.socket_connect_timeout
			socket_accept_timeout := cfg.socket_accept_timeout
		end

invariant
	server_attached: server /= Void

note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
