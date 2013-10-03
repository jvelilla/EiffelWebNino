note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

deferred class
	HTTP_CONNECTION_POOL

inherit
	CONCURRENT_POOL [HTTP_CONNECTION_HANDLER]
		rename
			new_separate_item as new_connection_handler,
			release_item as release_connection_handler
		end

feature -- Access

	is_verbose: BOOLEAN
			-- Is using verbose output for logging?

feature -- Change

	set_is_verbose (v: BOOLEAN)
			-- Set `is_verbose' to `v'.
		do
			is_verbose := v
		end

--	process_incoming_connection (a_socket: separate TCP_STREAM_SOCKET; a_flag_single_threaded: BOOLEAN)
--		require
--			not is_full and not stop_requested
--		local
--			soc: separate TCP_STREAM_SOCKET
--		do
--			if attached separate_item as h then
--				create soc.make_duplicate (a_socket)
--				process_connection_handler (h, a_socket, a_flag_single_threaded)
--			else
--				check is_not_full: False end
--			end
--		end

--	process_connection_handler (h: attached like separate_item; a_socket: separate TCP_STREAM_SOCKET; a_flag_single_threaded: BOOLEAN)
--		require
----			no_error: not h.has_error
--		do
--			h.set_client_socket (a_socket)
--			if h.has_error then
--				h.release
--			else
--				h.receive_message_and_send_reply (a_flag_single_threaded)
--			end
--		rescue
----			log ("Releasing handler after exception!")
--			h.release
--			a_socket.cleanup
--		end

note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
