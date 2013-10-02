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
	HTTP_CONSTANTS

	SHARED_EXECUTION_ENVIRONMENT

feature {NONE} -- Initialization

	make (a_server: like server)
			-- Creates a {HTTP_HANDLER}, assigns the server and initialize various values
			--
			-- `a_server': The main server object
		require
			a_server_attached: a_server /= Void
		local
			n: INTEGER
		do
			server := a_server
			is_stop_requested := False
			import_configuration (separate_server_configuration (a_server))
			if force_single_threaded then
				n := 1
			else
				n := max_concurrent_connections
			end
			build_pool (n)
		ensure
			server_set: a_server ~ server
		end

	build_pool (n: INTEGER)
		deferred
		end

	initialize_pool (p: like pool; n: INTEGER)
		do
			p.set_count (n)
			p.set_is_verbose (is_verbose)
		end

feature -- Output

	log (a_message: READABLE_STRING_8)
			-- Log `a_message'
		do
			server_log_message (a_message, server)
		end

	server_log_message (a_message: READABLE_STRING_8; a_server: like server)
		do
			a_server.log (a_message)
		end

feature -- Execution

	execute
			-- <Precursor>
			-- Creates a socket and connects to the http server.
		local
			l_listening_socket: detachable TCP_STREAM_SOCKET
			l_http_port: INTEGER
		do
			is_terminated := False
			launched := False
			port := 0
			is_stop_requested := False
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
					is_stop_requested
				loop
					l_listening_socket.accept
					if not is_stop_requested then
						if attached l_listening_socket.accepted as l_thread_http_socket then
							l_listening_socket.set_timeout (0)
							process_connection (l_thread_http_socket, pool)
						end
						is_stop_requested := stop_requested_on_server (server)
											 or else stop_requested_on_pool (pool)

					end
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

	process_connection (a_socket: TCP_STREAM_SOCKET; a_pool: like pool)
			-- Process incoming connection
			-- note that the precondition matters for scoop synchronization.
		require
			concurrency: not a_pool.is_full or a_pool.stop_requested or is_stop_requested
		local
			h: detachable separate HTTP_CONNECTION_HANDLER
		do
			request_counter := request_counter + 1
			if is_verbose then
				log ("#" + request_counter.out + "# Incoming connection...(socket:" + a_socket.descriptor.out + ")")
			end

			is_stop_requested := is_stop_requested or a_pool.stop_requested
			if is_stop_requested then
			else
				h := a_pool.separate_item
			end
			if h /= Void then
				process_connection_handler (h, a_socket)
			else
				check is_stop_requested: is_stop_requested end
				a_socket.cleanup
			end
		end

	process_connection_handler (hdl: separate HTTP_CONNECTION_HANDLER; a_socket: TCP_STREAM_SOCKET)
		require
			not hdl.has_error
		do
				--| FIXME jfiat [2011/11/03] : should use a Pool of Threads/Handler to process this connection
				--| also handle permanent connection...?

			hdl.set_client_socket (a_socket)
			if not hdl.has_error then
				hdl.set_logger (server)
				hdl.receive_message_and_send_reply (force_single_threaded)
			else
				log ("Error set_client_socket")
			end
				-- Clean original socket, the handler has a duplicate socket.
			if is_verbose then
				log ("connection completed...")
			end
		rescue
			log ("Releasing handler after exception!")
			hdl.release
			a_socket.cleanup
		end

feature {NONE} -- Access

	pool: separate HTTP_CONNECTION_POOL
			-- Pool of separate connection handlers.

	request_counter: INTEGER
			-- request counter, incremented for each new incoming connection.

feature {HTTP_CONNECTION_POOL} -- Factory

	connection_handler (a_pool: like pool): detachable separate HTTP_CONNECTION_HANDLER
		do
			is_stop_requested := is_stop_requested or a_pool.stop_requested
			if is_stop_requested or else a_pool.is_full then
				if is_verbose then
					log ("Stop requested...")
				end
			else
				Result := a_pool.separate_item
			end
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
			is_terminated := True
		ensure
			stopped: not launched
		end

feature -- Access

	port: INTEGER
			-- Listening port.
			--| 0: not launched

feature -- Status

	is_terminated: BOOLEAN
			-- Is terminated?

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

feature {NONE} -- Configuration: initialization

	import_configuration (cfg: like server_configuration)
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

feature -- Configuration: access

	is_verbose: BOOLEAN
			-- Is verbose for output messages.

	force_single_threaded: BOOLEAN

	http_server_name: detachable READABLE_STRING_8

	http_server_port: INTEGER

	max_tcp_clients: INTEGER

	max_concurrent_connections: INTEGER

	socket_connect_timeout: INTEGER

	socket_accept_timeout: INTEGER

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
			-- FIXME: we should probably remove this possibility, check with EWF if this is needed.
			Result := a_server.stop_requested
		end

feature {NONE} -- Access: pool		

	stop_requested_on_pool (p: like pool): BOOLEAN
		do
			Result := p.stop_requested
		end

invariant
	server_attached: server /= Void
	pool_attached: pool /= Void

note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
