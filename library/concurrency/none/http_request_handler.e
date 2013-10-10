note
	description : "Concurrent specific feature to implemente HTTP_REQUEST_HANDLER"
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

deferred class
	HTTP_REQUEST_HANDLER

inherit
	HTTP_REQUEST_HANDLER_I

feature -- Change

	set_client_socket (a_socket: separate TCP_STREAM_SOCKET)
		do
			client_socket := a_socket
		end

note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
