note
	description: "Summary description for {HTTP_SERVER_CONFIGURATION}."
	date: "$Date$"
	revision: "$Revision$"

class
	HTTP_SERVER_CONFIGURATION

create
	make

feature {NONE} -- Initialization

	make
		do
			http_server_port := 80
			max_concurrent_connections := 100
			max_tcp_clients := 100
			socket_accept_timeout := 1_000
			socket_connect_timeout := 5_000
			keep_alive_timeout := 5
		end

feature -- Access

	Server_details: STRING_8 = "Server : NINO Eiffel Server"

	http_server_name: detachable READABLE_STRING_8 assign set_http_server_name
	http_server_port: INTEGER assign set_http_server_port
	max_tcp_clients: INTEGER assign set_max_tcp_clients
	max_concurrent_connections: INTEGER assign set_max_concurrent_connections
	socket_accept_timeout: INTEGER assign set_socket_accept_timeout
	socket_connect_timeout: INTEGER assign set_socket_connect_timeout
	force_single_threaded: BOOLEAN assign set_force_single_threaded
		do
			Result := (max_concurrent_connections = 0)
		end

	is_verbose: BOOLEAN assign set_is_verbose
			-- Display verbose message to the output?

	keep_alive_timeout: INTEGER assign set_keep_alive_timeout
			-- Persistent connection timeout
			-- Timeout unit in Seconds.	

feature -- Element change

	set_http_server_name (v: detachable READABLE_STRING_8)
		do
			if v = Void then
				http_server_name := Void
			else
				create {IMMUTABLE_STRING_8} http_server_name.make_from_string (v)
			end
		end

	set_http_server_port (v: like http_server_port)
		do
			http_server_port := v
		end

	set_max_tcp_clients (v: like max_tcp_clients)
		do
			max_tcp_clients := v
		end

	set_max_concurrent_connections (v: like max_concurrent_connections)
		do
			max_concurrent_connections := v
		end

	set_socket_accept_timeout (v: like socket_accept_timeout)
		do
			socket_accept_timeout := v
		end

	set_socket_connect_timeout (v: like socket_connect_timeout)
		do
			socket_connect_timeout := v
		end

	set_force_single_threaded (v: like force_single_threaded)
		do
			if v then
				set_max_concurrent_connections (0)
			end
		end

	set_is_verbose (b: BOOLEAN)
			-- Set `is_verbose' to `b'
		do
			is_verbose := b
		end


	set_keep_alive_timeout (a_seconds: like keep_alive_timeout)
			-- Set `keep_alive_timeout' with `a_seconds'
		do
			keep_alive_timeout := a_seconds
		ensure
			keep_alive_timeout_set: keep_alive_timeout = a_seconds
		end


note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
