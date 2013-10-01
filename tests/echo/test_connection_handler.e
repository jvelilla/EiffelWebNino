note
	description: "Summary description for {AGENT_CONNECTION_HANDLER}."
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_CONNECTION_HANDLER

inherit
	HTTP_CONNECTION_HANDLER

	SHARED_EXECUTION_ENVIRONMENT

create
	make

feature -- Request processing

	process_request (a_handler: HTTP_CONNECTION_HANDLER; a_socket: TCP_STREAM_SOCKET)
			-- Process request ...
		local
			response: HTTP_RESPONSE
			l_uri: READABLE_STRING_8
			s: STRING_8
			l_wait: detachable STRING_8
			l_wait_nanosec: INTEGER_64
			l_map: HASH_TABLE [STRING, STRING]
			i: INTEGER
		do
			debug ("nino")
				io.put_string ("Incoming connection [" + a_socket.descriptor.out + "] " + ($a_handler).out + "%N")
			end

			l_uri := a_handler.uri
			s := "Request " + a_handler.method + " " + l_uri
			s.append (" socket=" + a_socket.descriptor.out)

			l_map := a_handler.request_header_map
			across
				l_map as c
			loop
				s.append_character (' ')
				s.append (c.key)
				s.append_character ('=')
				s.append (c.item)
			end

			if l_uri.starts_with ("/wait/") then
				create l_wait.make_from_string (l_uri)
				l_wait.remove_head (6)
				i := l_wait.index_of ('?', 1)
				if i > 0 then
					l_wait.keep_head (i - 1)
				end
				i := l_wait.index_of ('/', 1)
				if i > 0 then
					l_wait.keep_head (i - 1)
				end
				if l_wait.is_integer_64 then
					l_wait_nanosec := l_wait.to_integer_64 * {INTEGER_64} 1_000_000
					execution_environment.sleep (l_wait_nanosec)
				end
			elseif l_uri.same_string ("/shutdown/") then
				shutdown_server
			end

			create response
			response.set_status_code ("200")
			response.set_content_type ("text/plain")
			response.set_content_length (s.count)
			response.set_reply_text (s)
			a_socket.put_string (response.reply_header + response.reply_text)


			debug ("nino")
				io.put_string ("Finished connection [" + a_socket.descriptor.out + "] " + ($a_handler).out + "%N")
			end
		end

	shutdown_server
		do
			if attached pool as p then
				separate_shutdown_server (p)
			end
		end

	separate_shutdown_server (p: attached like pool)
		do
			p.gracefull_stop
		end

end
