note
	description: "Summary description for {HTTP_CONNECTION_HANDLER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	HTTP_CONNECTION_HANDLER

inherit
	HTTP_CONNECTION_HANDLER_I
		redefine
			initialize
		end

create
	make

feature {NONE} -- Initialization

	initialize
		local
			n: INTEGER
		do
			n := max_concurrent_connections (server)
			create pool.make (n.to_natural_32)
		end

feature -- Access

	is_shutdown_requested: BOOLEAN

--	stop_requested_on_server (a_server: like server): BOOLEAN
--		do
--			-- FIXME: we should probably remove this possibility, check with EWF if this is needed.
--			Result := a_server.is_stop_requested
--		end

	max_concurrent_connections (a_server: like server): INTEGER
		do
			Result := a_server.configuration.max_concurrent_connections
		end

feature {HTTP_SERVER} -- Execution

	shutdown
		do
			if not is_shutdown_requested then
				is_shutdown_requested := True
				pool_gracefull_stop (pool)
			end
		end

	pool_gracefull_stop (p: like pool)
		do
			p.terminate
		end

	process_incoming_connection (a_socket: TCP_STREAM_SOCKET)
		local
			h: HTTP_REQUEST_HANDLER
		do
			debug ("dbglog")
				dbglog (generator + ".before process_incoming_connection {"+ a_socket.descriptor.out +"} -- SCOOP WAIT!")
			end
			process_connection (a_socket, pool)
			debug ("dbglog")
				dbglog (generator + ".after process_incoming_connection {"+ a_socket.descriptor.out +"}")
			end
		end

	process_connection (a_socket: TCP_STREAM_SOCKET; a_pool: like pool)
			-- Process incoming connection
			-- note that the precondition matters for scoop synchronization.
		require
			concurrency: not a_pool.over or is_shutdown_requested
		do
			debug ("dbglog")
				dbglog (generator + ".ENTER process_connection {"+ a_socket.descriptor.out +"}")
			end
			if is_shutdown_requested then
				a_socket.cleanup
			else
				process_connection_handler (factory.new_handler, a_socket)
			end
			debug ("dbglog")
				dbglog (generator + ".LEAVE process_connection {"+ a_socket.descriptor.out +"}")
			end
		end

	process_connection_handler (hdl: separate HTTP_REQUEST_HANDLER; a_socket: TCP_STREAM_SOCKET)
		require
			not hdl.has_error
		do
				--| FIXME jfiat [2011/11/03] : should use a Pool of Threads/Handler to process this connection
				--| also handle permanent connection...?

			debug ("dbglog")
				dbglog (generator + ".ENTER process_connection_handler {"+ a_socket.descriptor.out +"}")
			end
			hdl.set_client_socket (a_socket)
			if not hdl.has_error then
--				hdl.set_logger (server)
				pool.add_work (agent hdl.execute)
--				hdl.execute
			else
				log ("Internal error (set_client_socket failed)")
			end
			debug ("dbglog")
				dbglog (generator + ".LEAVE process_connection_handler {"+ a_socket.descriptor.out +"}")
			end
		rescue
			log ("Releasing handler after exception!")
			hdl.release
			a_socket.cleanup
		end

feature {HTTP_SERVER} -- Status report

	wait_for_completion
			-- Wait until Current is ready for shutdown
		do
			wait_for_pool_completion (pool)
		end

	wait_for_pool_completion (p: like pool)
		do
			p.wait_for_completion
		end

feature {NONE} -- Access

	pool: THREAD_POOL [HTTP_REQUEST_HANDLER] --ANY] --POOLED_THREAD [HTTP_REQUEST_HANDLER]]
			-- Pool of separate connection handlers.

invariant
	pool_attached: pool /= Void

note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
