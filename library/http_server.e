note
	description: "Summary description for {HTTP_SERVER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	HTTP_SERVER

inherit
	HTTP_SERVER_LOGGER

create
	make

feature -- Initialization

	make (cfg: HTTP_SERVER_CONFIGURATION)
		do
			configuration := cfg
			output := io.error
		end

	setup (a_http_handler: separate HTTP_HANDLER)
		obsolete
			"Use `launch' [Oct-2013]"
		do
			launch (a_http_handler)
		end

	launch (a_http_handler: separate HTTP_HANDLER)
		require
			a_http_handler_valid: a_http_handler /= Void
		do
			is_terminated := False
			if is_verbose then
				log ("%N%NStarting Web Application Server (port="+ http_server_port.out +"):%N")
			end
			stop_requested := False
			a_http_handler.execute
			on_terminated (a_http_handler)
		end

	on_terminated (h: separate HTTP_HANDLER)
		require
			h.is_terminated
		do
			if h.is_terminated then
				log ("%N%NTerminating Web Application Server (port="+ http_server_port.out +"):%N")
			end
			output.flush
			output.close
		end

	shutdown_server
		do
			stop_requested := True
		end

feature	-- Access

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

	stop_requested: BOOLEAN
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
