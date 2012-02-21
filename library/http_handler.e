note
	description: "[
			Instance of  HTTP_CONNECTION_HANDLER
			is in charge to process the incoming connection without any specific analysis

		]"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	HTTP_HANDLER

inherit
	ANY

	HTTP_CONSTANTS

feature {NONE} -- Initialization

	make (a_server: like server)
			-- Creates a {HTTP_HANDLER}, assigns the server and initialize various values
			--
			-- `a_server': The main server object
		require
			a_server_attached: a_server /= Void
		do
			server := a_server
			is_stop_requested := False
		ensure
			server_set: a_server ~ server
		end

feature -- Output

	log (a_message: READABLE_STRING_8)
			-- Output message
		do
			io.put_string (a_message)
		end

feature -- Inherited Features

	execute
			-- <Precursor>
			-- Creates a socket and connects to the http server.
		local
			l_listening_socket: detachable TCP_STREAM_SOCKET
			l_http_port: INTEGER
		do
			launched := False
			port := 0
			is_stop_requested := False
			l_http_port := http_server_port
			create l_listening_socket.make_server_by_port (l_http_port)
			if not l_listening_socket.is_bound then
				if is_verbose then
					log ("Socket could not be bound on port " + l_http_port.out )
				end
			else
				l_http_port := l_listening_socket.port
				from
					l_listening_socket.listen (max_tcp_clients)
					if is_verbose then
						log ("%NHTTP Connection Server ready on port " + l_http_port.out +" : http://localhost:" + l_http_port.out + "/%N")
					end
					on_launched (l_http_port)
				until
					is_stop_requested
				loop
					l_listening_socket.accept
					if not is_stop_requested then
						if attached l_listening_socket.accepted as l_thread_http_socket then
							process_connection (l_thread_http_socket)
						end
					end
					is_stop_requested := stop_requested_on_server (server)
				end
				l_listening_socket.cleanup
				check
					socket_is_closed: l_listening_socket.is_closed
				end
			end
			if launched then
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
			if launched then
				on_stopped
			end
			is_stop_requested := True
			retry
		end

	process_connection (a_socket: TCP_STREAM_SOCKET)
		do
			if is_verbose then
				log ("Incoming connection ...%N")
			end
			call_receive_message_and_send_reply (new_http_connection_handler, a_socket)
		end

	call_receive_message_and_send_reply (hdl: separate HTTP_CONNECTION_HANDLER; a_socket: separate TCP_STREAM_SOCKET)
		do
			hdl.set_client_socket (a_socket)
			if force_single_threaded then
				hdl.receive_message_and_send_reply (True)
			else
				pool.add_connection (hdl)
--				hdl.receive_message_and_send_reply (False)
			end
		end

	pool: HTTP_CONNECTION_POOL
		local
			l_pool: like internal_pool
		do
			l_pool := internal_pool
			if l_pool = Void then
				create l_pool.make (10)
				internal_pool := l_pool
			end
			Result := l_pool
		end

	internal_pool: detachable like pool

feature {NONE} -- Factory

	new_http_connection_handler: separate HTTP_CONNECTION_HANDLER
		deferred
		end

feature -- Event

	on_launched (a_port: INTEGER)
			-- Server launched using port `a_port'
		require
			not_launched: not launched
		do
			launched := True
			port := a_port
		ensure
			launched: launched
		end

	on_stopped
			-- Server stopped
		require
			launched: launched
		do
			launched := False
		ensure
			stopped: not launched
		end

feature -- Access

	port: INTEGER
			-- Listening port.
			--| 0: not launched

feature -- Status

	is_stop_requested: BOOLEAN
			-- Set true to stop accept loop

	launched: BOOLEAN
			-- Server launched and listening on `port'

feature -- Status setting

	shutdown
			-- Stops the thread
		do
			is_stop_requested := True
		end

feature -- Access: configuration

	is_verbose: BOOLEAN
			-- Is verbose for output messages.
		do
			Result := separate_is_verbose (server_configuration)
		end

	force_single_threaded: BOOLEAN
		do
			Result := separate_force_single_threaded (server_configuration)
		end

	http_server_port: INTEGER
		do
			Result := separate_http_server_port (server_configuration)
		end

	max_tcp_clients: INTEGER
		do
			Result := separate_max_tcp_clients (server_configuration)
		end

feature {NONE} -- Access: server

	server: separate HTTP_SERVER
			-- The main server object

	server_configuration: separate HTTP_SERVER_CONFIGURATION
			-- The main server's configuration
		do
			Result := separate_server_configuration (server)
		end

	separate_server_configuration (a_server: like server): separate HTTP_SERVER_CONFIGURATION
			-- The main server's configuration
		do
			Result := a_server.configuration
		end

	stop_requested_on_server (a_server: like server): BOOLEAN
		do
			Result := a_server.stop_requested
		end

feature {NONE} -- Access: configuration

	separate_is_verbose (conf: separate HTTP_SERVER_CONFIGURATION): BOOLEAN
		do
			Result := conf.is_verbose
		end

	separate_force_single_threaded (conf: separate HTTP_SERVER_CONFIGURATION): BOOLEAN
		do
			Result := conf.force_single_threaded
		end

	separate_http_server_port (conf: separate HTTP_SERVER_CONFIGURATION): INTEGER
		do
			Result := conf.http_server_port
		end

	separate_max_tcp_clients (conf: separate HTTP_SERVER_CONFIGURATION): INTEGER
		do
			Result := conf.max_tcp_clients
		end

invariant
	server_attached: server /= Void

note
	copyright: "2011-2012, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
