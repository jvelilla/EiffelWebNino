note
	description: "Summary description for {HTTP_SERVER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	HTTP_SERVER

inherit
	HTTP_SERVER_LOGGER

	HTTP_DEBUG_LOGGER

create
	make

feature -- Initialization

	make (cfg: HTTP_SERVER_CONFIGURATION; a_factory: like factory)
		do
			configuration := cfg
			factory := a_factory
			output := io.error
			create controller
		end

	launch (a_http_listener: HTTP_LISTENER_I)
		require
			a_http_listener_valid: a_http_listener /= Void
		do
			is_terminated := False
			if is_verbose then
				log ("%N%NStarting Web Application Server (port=" + http_server_port.out + "):%N")
			end
			is_stop_requested := False
			listener := a_http_listener
			a_http_listener.execute
			on_terminated (a_http_listener)
		end

	on_terminated (h: separate HTTP_LISTENER_I)
		require
			h.is_terminated
		do
			if h.is_terminated then
				log ("%N%NTerminating Web Application Server (port="+ http_server_port.out +"):%N")
			end
			output.flush
			output.close
			listener := Void
		end

	shutdown_server
		do
			debug ("dbglog")
				dbglog ("Shutdown requested")
			end
			is_stop_requested := True
			controller_shutdown (controller)
		end

	controller_shutdown (ctl: attached like controller)
		do
			ctl.shutdown
		end

feature	-- Access

	listener: detachable HTTP_LISTENER_I

	controller: separate HTTP_CONTROLLER

	factory: separate HTTP_CONNECTION_HANDLER_FACTORY

	is_terminated: BOOLEAN
			-- Is terminated?

	is_verbose: BOOLEAN
		do
			Result := configuration_is_verbose (configuration)
		end

	http_server_port: INTEGER
		do
			Result := configuration_http_server_port (configuration)
		end

	configuration: HTTP_SERVER_CONFIGURATION
			-- Configuration of the server

	is_stop_requested: BOOLEAN
			-- Stops the server

feature {NONE} -- Access

	configuration_is_verbose (conf: HTTP_SERVER_CONFIGURATION): BOOLEAN
		do
			Result := conf.is_verbose
		end

	configuration_http_server_port (conf: HTTP_SERVER_CONFIGURATION): INTEGER
		do
			Result := conf.http_server_port
		end

feature -- Output

	output: FILE

	set_log_output (f: FILE)
		do
			output := f
		end

	log (a_message: separate READABLE_STRING_8)
			-- Log `a_message'
		do
			output.put_string (a_message)
			output.put_new_line
		end

note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
