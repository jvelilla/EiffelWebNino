note
	description: "Summary description for {AGENT_CONNECTION_HANDLER}."
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_CONNECTION_HANDLER

inherit
	HTTP_REQUEST_HANDLER

	SHARED_EXECUTION_ENVIRONMENT

	HTTP_DEBUG_FACILITIES

create
	make

feature -- Request processing

	process_request (a_socket: TCP_STREAM_SOCKET)
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
				io.put_string ("Incoming connection [" + a_socket.descriptor.out + "] " + ($Current).out + "%N")
			end

			l_uri := uri
			s := "Request " + method + " " + l_uri
			s.append (" socket=" + a_socket.descriptor.out)

			l_map := request_header_map
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
					check attached client_socket as l_socket and then attached l_socket.descriptor.out as d then
						debug ("dbglog")
							dbglog (generator + ".before sleep {" + d + "}")
						end
						execution_environment.sleep (l_wait_nanosec)
						debug ("dbglog")
							dbglog (generator + ".after sleep {" + d + "}")
						end
					end
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
				io.put_string ("Finished connection [" + a_socket.descriptor.out + "] " + ($Current).out + "%N")
			end
		end

feature -- Access

	controller: detachable separate HTTP_CONTROLLER

feature -- Change

	set_controller (obj: like controller)
		do
			controller := obj
		end

	shutdown_server
		do
			if attached controller as obj then
				separate_shutdown_server (obj)
			end
		end

	separate_shutdown_server (obj: attached like controller)
		do
			obj.shutdown
		end


end
