note
	description: "Summary description for {HTTP_SERVER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	HTTP_SERVER

inherit
	HTTP_CONSTANTS

	HTTP_DEBUG_FACILITIES

	HTTP_SERVER_LOGGER

create
	make

feature {NONE} -- Initialization

	make (a_cfg: HTTP_SERVER_CONFIGURATION; a_factory: like factory)
			-- `a_cfg': server configuration
			-- `a_factory': connection handler builder
		do
			configuration := a_cfg
			factory := a_factory
			output := io.error

			build_controller

			import_configuration (a_cfg)

			initialize
		end

	build_controller
			-- Build `controller'.
		do
			create controller
		end

	initialize
			-- Initialize Current server.
		do
			is_shutdown_requested := False
		end

feature	-- Access

	is_verbose: BOOLEAN
			-- Is verbose for output messages.

	configuration: HTTP_SERVER_CONFIGURATION
			-- Associated server configuration.

	controller: separate HTTP_CONTROLLER

	factory: separate HTTP_REQUEST_HANDLER_FACTORY


feature -- Access: listening

	port: INTEGER
			-- Effective listening port.
			--| If 0 then it is not launched successfully!

feature -- Status: listening

	is_launched: BOOLEAN
			-- Server launched and listening on `port'	

	is_terminated: BOOLEAN
			-- Is terminated?

	is_shutdown_requested: BOOLEAN
			-- Set true to stop accept loop

feature {NONE} -- Access: server

	request_counter: INTEGER
			-- request counter, incremented for each new incoming connection.			

feature -- Execution

	launch
		do
			is_terminated := False
			if is_verbose then
				log ("%N%NStarting Web Application Server (port=" + configuration.http_server_port.out + "):%N")
			end
			is_shutdown_requested := False
			listen
			on_terminated
		end

	on_terminated
		require
			is_terminated
		do
			if is_terminated then
				log ("%N%NTerminating Web Application Server (port="+ port.out +"):%N")
			end
			output.flush
			output.close
		end

	shutdown_server
		do
			debug ("dbglog")
				dbglog ("Shutdown requested")
			end
			is_shutdown_requested := True
			controller_shutdown (controller)
		end

	controller_shutdown (ctl: attached like controller)
		do
			ctl.shutdown
		end

feature -- Listening

	listen
			-- <Precursor>
			-- Creates a socket and connects to the http server.
			-- `a_server': The main server object
		local
			l_listening_socket,
			l_accepted_socket: detachable TCP_STREAM_SOCKET
			l_http_port: INTEGER
			l_connection_handler: HTTP_CONNECTION_HANDLER
		do
			is_terminated := False
			is_launched := False
			port := 0
			is_shutdown_requested := False
			l_http_port := configuration.http_server_port
			if
				attached configuration.http_server_name as l_servername and then
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
				create l_connection_handler.make (Current)
				from
--					l_listening_socket.set_connect_timeout (socket_connect_timeout)
--					l_listening_socket.set_accept_timeout (socket_accept_timeout)
					l_listening_socket.listen (configuration.max_tcp_clients)
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
							l_accepted_socket.set_timeout (600)
							l_accepted_socket.set_non_blocking
							request_counter := request_counter + 1
							if is_verbose then
								log ("#" + request_counter.out + "# Incoming connection...(socket:" + l_accepted_socket.descriptor.out + ")")
							end
							debug ("dbglog")
								dbglog (generator + ".before process_incoming_connection {" + l_accepted_socket.descriptor.out + "}" )
							end
							process_incoming_connection (l_accepted_socket, l_connection_handler)
							debug ("dbglog")
								dbglog (generator + ".after process_incoming_connection {" + l_accepted_socket.descriptor.out + "}")
							end
						end
					end
					update_is_shutdown_requested (l_connection_handler)
				end
				wait_for_connection_handler_completion (l_connection_handler)
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

feature {NONE} -- Helpers

	wait_for_connection_handler_completion (h: HTTP_CONNECTION_HANDLER)
		do
			h.wait_for_completion
			debug ("dbglog")
				dbglog ("Shutdown ready from connection_handler point of view")
			end
		end

	process_incoming_connection (a_socket: TCP_STREAM_SOCKET; a_connection_handler: HTTP_CONNECTION_HANDLER)
		do
			a_connection_handler.process_incoming_connection (a_socket)
		end

	update_is_shutdown_requested (a_connection_handler: HTTP_CONNECTION_HANDLER)
		do
			is_shutdown_requested := is_shutdown_requested or shutdown_requested (controller)
			if is_shutdown_requested then
				a_connection_handler.shutdown
			end
		end

	shutdown_requested (a_controller: separate HTTP_CONTROLLER): BOOLEAN
			-- Shutdown requested on separate `a_controller'?
		do
			Result := a_controller.shutdown_requested
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

feature {NONE} -- Configuration: initialization

	import_configuration (cfg: HTTP_SERVER_CONFIGURATION)
		do
			is_verbose := cfg.is_verbose
		end

feature -- Output

	output: FILE

	set_log_output (f: FILE)
		do
			output := f
		end

	log (a_message: separate READABLE_STRING_8)
			-- Log `a_message'
		do
			output.put_string (a_message)
			output.put_new_line
		end

note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
