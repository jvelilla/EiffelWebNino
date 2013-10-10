note
	description: "[
			 Instance of HTTP_REQUEST_HANDLER will process the incoming connection
			 and extract information on the request and the server
		 ]"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	HTTP_REQUEST_HANDLER

inherit
	HTTP_REQUEST_HANDLER_I
		redefine
			release
		end

feature -- Change

	set_client_socket (a_socket: separate TCP_STREAM_SOCKET)
		do
			client_socket := a_socket
		end

feature {CONCURRENT_POOL, HTTP_CONNECTION_HANDLER_I} -- Basic operation		

	release
		local
			d: STRING
		do
			if attached client_socket as l_socket then
				d := l_socket.descriptor.out
				debug ("dbglog")
					dbglog (generator + ".release: ENTER {" + d + "}")
				end
				Precursor {HTTP_REQUEST_HANDLER_I}
				debug ("dbglog")
					dbglog (generator + ".release: LEAVE {" + d + "}")
				end
			else
				Precursor {HTTP_REQUEST_HANDLER_I}
			end
		end

note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
