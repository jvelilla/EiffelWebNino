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
--			set_client_socket,			
			release,
			reset
		end

	CONCURRENT_POOL_ITEM
		redefine
			release
		end

feature {NONE} -- Initialization

	reset
		do
			if attached client_socket_source as l_sock then
				cleanup_separate_socket (l_sock)
			end
			Precursor
			client_socket_source := Void
		end

	cleanup_separate_socket (a_socket: attached like client_socket_source)
		do
			a_socket.cleanup
		end

feature -- Access

	client_socket_source: detachable separate TCP_STREAM_SOCKET
				-- Associated original client socket
				-- kept to avoid being closed when disposed,
				-- and thus avoid closing related `client_socket'.		

feature -- Change

	set_client_socket (a_socket: separate TCP_STREAM_SOCKET)
		local
			retried: BOOLEAN
		do
			if retried then
				has_error := True
			else
				create client_socket.make_from_separate (a_socket)
				client_socket_source := a_socket
			end
		rescue
			retried := True
			retry
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
				Precursor {CONCURRENT_POOL_ITEM}
				debug ("dbglog")
					dbglog (generator + ".release: LEAVE {" + d + "}")
				end
			else
				Precursor {HTTP_REQUEST_HANDLER_I}
				Precursor {CONCURRENT_POOL_ITEM}
			end
		end

note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
