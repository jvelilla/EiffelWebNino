note
	description: "Summary description for {AGENT_CONNECTION_HANDLER}."
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_CONNECTION_HANDLER

inherit
	HTTP_CONNECTION_HANDLER

create
	make

feature -- Request processing

	process_request (a_handler: HTTP_CONNECTION_HANDLER; a_socket: TCP_STREAM_SOCKET)
			-- Process request ...
		local
			response: HTTP_RESPONSE
			s: STRING_8
			l_map: HASH_TABLE [STRING, STRING]
		do
			debug ("nino")
				io.put_string ("Incoming connection [" + a_socket.descriptor.out + "] " + ($a_handler).out + "%N")
			end
			s := "Request " + a_handler.method + " " + a_handler.uri
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

end
