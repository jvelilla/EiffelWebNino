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

	SCOOP_POOLABLE_ITEM

	HTTP_CONNECTION_HANDLER_I
		redefine
			make
		end

	HTTP_CONSTANTS
		export
			{NONE} all
		end

feature {NONE} -- Initialization

	make (a_is_verbose: BOOLEAN)
			-- Initialize Current connection handler
			-- sets the current_request_message to empty.
		do
			Precursor (a_is_verbose)
			is_verbose := a_is_verbose
			reset
		end

	reset
		do
			has_error := False
			version := Void
			remote_info := Void
--			if attached client_socket_source as l_sock then
--				cleanup_separate_socket (l_sock)
--			end
			client_socket_source := Void

			if attached client_socket as l_sock then
				l_sock.cleanup
				client_socket := Void
			end
			create method.make_empty
			create uri.make_empty
			create request_header.make_empty
			create request_header_map.make (10)
		end

--	cleanup_separate_socket (a_socket: attached like client_socket_source)
--		do
--			a_socket.cleanup
--		end

feature -- Status report

	is_verbose: BOOLEAN

	set_client_socket (a_socket: separate TCP_STREAM_SOCKET)
		require
			socket_attached: a_socket /= Void
			socket_valid: a_socket.is_open_read and then a_socket.is_open_write
			a_http_socket: not a_socket.is_closed
		local
			retried: BOOLEAN
		do
			if retried then
				has_error := True
			else
				create client_socket.make_duplicate (a_socket)
			end
			client_socket_source := a_socket
		rescue
			retried := True
			retry
		end

feature -- Output

	logger: detachable separate HTTP_SERVER_LOGGER

	set_logger (a_logger: like logger)
		do
			logger := a_logger
		end

	log (m: STRING)
		do
			if attached logger as l_logger then
				separate_log (m, l_logger)
			else
				io.put_string (m + "%N")
			end
		end

	separate_log (m: STRING; a_logger: separate HTTP_SERVER_LOGGER)
		do
			a_logger.log (m)
		end

feature -- Access

	client_socket: detachable TCP_STREAM_SOCKET

	client_socket_source: detachable separate TCP_STREAM_SOCKET
				-- Associated original client socket
				-- kept to avoid being closed when disposed,
				-- and thus avoid closing related `client_socket'.

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
	            if has_error then
					check catch_bad_incoming_connection: False end
					if is_verbose then
						check invalid_incoming_request: False end
						log ("ERROR: invalid HTTP incoming request")
					end
				else
					process_request (Current, l_socket)
	            end
				reset
			else
				check has_client_socket: False end
				reset
			end
			release
		end

feature -- Request processing

	process_request (a_handler: HTTP_CONNECTION_HANDLER; a_socket: TCP_STREAM_SOCKET)
			-- Process request ...
		require
			no_error: not has_error
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

	has_error: BOOLEAN
			-- Error occurred during `analyze_request_message'

	method: STRING
			-- http verb

	uri: STRING
			--  http endpoint		

	version: detachable STRING
			--  http_version
			--| unused for now

	remote_info: detachable TUPLE [addr: STRING; hostname: STRING; port: INTEGER]
			-- Information related to remote client

feature -- Parsing

	analyze_request_message (a_socket: TCP_STREAM_SOCKET)
			-- Analyze message extracted from `a_socket' as HTTP request
        require
            input_readable: a_socket /= Void and then a_socket.is_open_read
        local
        	end_of_stream : BOOLEAN
        	pos,n : INTEGER
        	line : detachable STRING
			k, val: STRING
        	txt: STRING
			l_is_verbose: BOOLEAN
        do
            create txt.make (64)
			request_header := txt

			if attached next_line (a_socket) as l_request_line and then not l_request_line.is_empty then
				txt.append (l_request_line)
				txt.append_character ('%N')
				analyze_request_line (l_request_line)
			else
				has_error := True
			end

			l_is_verbose := is_verbose

			if not has_error or l_is_verbose then
					-- if `is_verbose' we can try to print the request, even if it is a bad HTTP request
				from
					line := next_line (a_socket)
				until
					line = Void or end_of_stream
				loop
					n := line.count
					if l_is_verbose then
						log (line)
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
			-- Analyze `line' as a HTTP request line
		require
			valid_line: line /= Void and then not line.is_empty
		local
			pos, next_pos: INTEGER
		do
			if is_verbose then
				log ("%N## Parse HTTP request line ##")
				log (line)
			end
			pos := line.index_of (' ', 1)
			method := line.substring (1, pos - 1)
			next_pos := line.index_of (' ', pos + 1)
			uri := line.substring (pos + 1, next_pos - 1)
			version := line.substring (next_pos + 1, line.count)
			has_error := method.is_empty
		end

	next_line (a_socket: TCP_STREAM_SOCKET): detachable STRING
			-- Next line fetched from `a_socket' is available.
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
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
