note
	description: "[
			 Instance of HTTP_CONNECTION_HANDLER will process the incoming connection
			 and extract information on the request and the server
		 ]"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	HTTP_CONNECTION_HANDLER

inherit
	ANY

	HTTP_CONNECTION_HANDLER_I

	HTTP_CONSTANTS

feature {NONE} -- Initialization

	make (a_is_verbose: BOOLEAN)
			-- Initialize Current connection handler
			-- sets the current_request_message to empty.
		do
--			create client_socket.make_duplicate (a_socket)
--			client_socket := a_socket
			is_verbose := a_is_verbose
			reset
		end

	reset
		do
			create method.make_empty
			create uri.make_empty
			create request_header.make_empty
			create request_header_map.make (10)
			remote_info := Void
		end

feature -- Status report

	is_verbose: BOOLEAN


	set_client_socket (a_socket: separate TCP_STREAM_SOCKET)
		require
			socket_attached: a_socket /= Void
--			socket_valid: a_socket.is_open_read and then a_socket.is_open_write
			a_http_socket: not a_socket.is_closed
		do
			create client_socket.make_duplicate (a_socket)
		end

feature -- Output

	log (m: STRING)
		do
			print (m)
		end

feature -- Access

	client_socket: detachable TCP_STREAM_SOCKET

feature -- Execution

	receive_message_and_send_reply (force_single_threaded: BOOLEAN)
		require
			socket_attached: attached client_socket as r_client_socket
--			socket_valid: r_client_socket.is_open_read and then r_client_socket.is_open_write
			a_http_socket: not r_client_socket.is_closed
		do
			if force_single_threaded then
				execute
			else
				launch
			end
		end

	execute
		local
			l_remote_info: detachable like remote_info
		do
			if attached client_socket as l_socket then
				create l_remote_info
				if attached l_socket.peer_address as l_addr then
					l_remote_info.addr := l_addr.host_address.host_address
					l_remote_info.hostname := l_addr.host_address.host_name
					l_remote_info.port := l_addr.port
					remote_info := l_remote_info
				end


	            analyze_request_message (l_socket)
				process_request (Current, l_socket)
				l_socket.cleanup
				client_socket := Void

				reset
			else
				check has_client_socket: False end
			end
		end

feature -- Request processing

	process_request (a_handler: HTTP_CONNECTION_HANDLER; a_socket: TCP_STREAM_SOCKET)
			-- Process request ...
		require
			a_handler_attached: a_handler /= Void
			a_uri_attached: a_handler.uri /= Void
			a_method_attached: a_handler.method /= Void
			a_header_map_attached: a_handler.request_header_map /= Void
			a_header_text_attached: a_handler.request_header /= Void
			a_socket_attached: a_socket /= Void
		deferred
		end

feature -- Access

	request_header: STRING
			-- Header' source

	request_header_map : HASH_TABLE [STRING,STRING]
			-- Contains key:value of the header

	method: STRING
			-- http verb

	uri: STRING
			--  http endpoint		

	version: detachable STRING
			--  http_version
			--| unused for now

	remote_info: detachable TUPLE [addr: STRING; hostname: STRING; port: INTEGER]

feature -- Parsing

	analyze_request_message (a_socket: TCP_STREAM_SOCKET)
        require
            input_readable: a_socket /= Void and then a_socket.is_open_read
        local
        	end_of_stream : BOOLEAN
        	pos,n : INTEGER
        	line : detachable STRING
			k, val: STRING
        	txt: STRING
        do
            create txt.make (64)
			line := next_line (a_socket)
			if line /= Void then
				analyze_request_line (line)
				txt.append (line)
				txt.append_character ('%N')

				request_header := txt
				from
					line := next_line (a_socket)
				until
					line = Void or end_of_stream
				loop
					n := line.count
					if is_verbose then
						log ("%N" + line)
					end
					pos := line.index_of (':',1)
					if pos > 0 then
						k := line.substring (1, pos-1)
						if line [pos+1].is_space then
							pos := pos + 1
						end
						if line [n] = '%R' then
							n := n - 1
						end
						val := line.substring (pos + 1, n)
						request_header_map.put (val, k)
					end
					txt.append (line)
					txt.append_character ('%N')
					if line.is_empty or else line [1] = '%R' then
						end_of_stream := True
					else
						line := next_line (a_socket)
					end
				end
			end
		end

	analyze_request_line (line: STRING)
		require
			line /= Void
		local
			pos, next_pos: INTEGER
		do
			if is_verbose then
				log ("%N## Parse HTTP request line ##")
				log ("%N")
				log (line)
			end
			pos := line.index_of (' ', 1)
			method := line.substring (1, pos - 1)
			next_pos := line.index_of (' ', pos + 1)
			uri := line.substring (pos + 1, next_pos - 1)
			version := line.substring (next_pos + 1, line.count)
		ensure
			not_void_method: method /= Void
		end

	next_line (a_socket: TCP_STREAM_SOCKET): detachable STRING
		require
			is_readable: a_socket.is_open_read
		do
			if a_socket.socket_ok then
				a_socket.read_line_thread_aware
				Result := a_socket.last_string
			end
		end

invariant
	request_header_attached: request_header /= Void

note
	copyright: "2011-2011, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
