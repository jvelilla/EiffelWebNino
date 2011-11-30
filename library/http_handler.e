note
	description: "Summary description for {HTTP_CONNECTION_HANDLER}."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	HTTP_HANDLER

inherit
	ANY

	HTTP_CONSTANTS

feature {NONE} -- Initialization

	make (a_main_server: like main_server)
			-- Creates a {HTTP_HANDLER}, assigns the main_server and initialize various values
			--
			-- `a_main_server': The main server object
		require
			a_main_server_attached: a_main_server /= Void
		do
			main_server := a_main_server
			is_stop_requested := False
		ensure
			main_server_set: a_main_server ~ main_server
		end

feature -- Output

	log (m: STRING)
		do
			print (m)
		end

feature -- Inherited Features

	execute
			-- <Precursor>
			-- Creates a socket and connects to the http server.
		local
			l_http_socket: detachable TCP_STREAM_SOCKET
			l_http_port: INTEGER
		do
			launched := False
			port := 0
			is_stop_requested := False
			l_http_port := http_server_port (main_server_configuration (main_server))
			create l_http_socket.make_server_by_port (l_http_port)
			if not l_http_socket.is_bound then
				if is_verbose then
					log ("Socket could not be bound on port " + l_http_port.out )
				end
			else
				l_http_port := l_http_socket.port
				from
					l_http_socket.listen (max_tcp_clients (main_server_configuration (main_server)))
					if is_verbose then
						log ("%NHTTP Connection Server ready on port " + l_http_port.out +" : http://localhost:" + l_http_port.out + "/%N")
					end
					on_launched (l_http_port)
				until
					is_stop_requested
				loop
					l_http_socket.accept
					if not is_stop_requested then
						if attached l_http_socket.accepted as l_thread_http_socket then
							process_connection (create {TCP_STREAM_SOCKET}.make_duplicate (l_thread_http_socket))
						end
					end
					is_stop_requested := stop_requested (main_server)
				end
				l_http_socket.cleanup
				check
					socket_is_closed: l_http_socket.is_closed
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

			if attached l_http_socket as ll_http_socket then
				ll_http_socket.cleanup
				check
					socket_is_closed: ll_http_socket.is_closed
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
			log ("Incoming connection...%N")
			call_receive_message_and_send_reply (new_http_connection_handler, a_socket)
		end

	call_receive_message_and_send_reply (hdl: separate HTTP_CONNECTION_HANDLER; a_socket: separate TCP_STREAM_SOCKET)
		do
			hdl.set_client_socket (a_socket)
			hdl.receive_message_and_send_reply (force_single_threaded)
		end

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

	is_verbose: BOOLEAN
			-- Is verbose for output messages.
		do
			Result := separate_is_verbose (main_server_configuration (main_server))
		end

	force_single_threaded: BOOLEAN
		do
			Result := separate_force_single_threaded (main_server_configuration (main_server))
		end

	is_stop_requested: BOOLEAN
			-- Set true to stop accept loop

	launched: BOOLEAN
			-- Server launched and listening on `port'

	port: INTEGER
			-- Listening port.
			--| 0: not launched

feature {NONE} -- Access

	main_server: separate HTTP_SERVER
			-- The main server object

	main_server_configuration (server: separate HTTP_SERVER): separate HTTP_SERVER_CONFIGURATION
			-- The main server's configuration
		do
			Result := server.configuration
		end

	separate_is_verbose (conf: separate HTTP_SERVER_CONFIGURATION): BOOLEAN
		do
			Result := conf.is_verbose
		end

	separate_force_single_threaded (conf: separate HTTP_SERVER_CONFIGURATION): BOOLEAN
		do
			Result := conf.force_single_threaded
		end

	http_server_port (conf: separate HTTP_SERVER_CONFIGURATION): INTEGER
		do
			Result := conf.http_server_port
		end

	max_tcp_clients (conf: separate HTTP_SERVER_CONFIGURATION): INTEGER
		do
			Result := conf.max_tcp_clients
		end

	stop_requested (server: separate HTTP_SERVER): BOOLEAN
		do
			Result := server.stop_requested
		end

feature -- Status setting

	shutdown
			-- Stops the thread
		do
			is_stop_requested := True
		end

--feature -- Execution

--	receive_message_and_send_reply (client_socket: separate TCP_STREAM_SOCKET)
--		require
--			socket_attached: client_socket /= Void
----			socket_valid: client_socket.is_open_read and then client_socket.is_open_write
--			a_http_socket: not client_socket.is_closed
--		deferred
--		end

invariant
	main_server_attached: main_server /= Void

note
	copyright: "2011-2011, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
