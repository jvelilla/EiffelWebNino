note
	description: "Summary description for {HTTP_SERVER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	HTTP_SERVER

inherit
	HTTP_SERVER_SHARED_CONFIGURATION

create
	make

feature -- Initialization

	make (cfg: separate HTTP_SERVER_CONFIGURATION)
		do
			configuration := cfg
			set_server_configuration (configuration)
		end

	setup (a_http_handler: separate HTTP_HANDLER)
		require
			a_http_handler_valid: a_http_handler /= Void
		do
			if is_verbose then
				log ("%N%N%N")
				log ("Starting Web Application Server (port="+ http_server_port.out +"):%N")
			end
			stop_requested := False
			a_http_handler.launch_and_wait
		end

	shutdown_server
		do
			stop_requested := True
		end

feature -- Output

	log (m: STRING)
		do
			io.put_string (m)
		end

feature	-- Access

	is_verbose: BOOLEAN
		do
			Result := separate_is_verbose (configuration)
		end

	http_server_port: INTEGER
		do
			Result := separate_http_server_port (configuration)
		end

	configuration: separate HTTP_SERVER_CONFIGURATION
			-- Configuration of the server

	stop_requested: BOOLEAN
			-- Stops the server

feature {NONE} -- Access

	separate_is_verbose (conf: separate HTTP_SERVER_CONFIGURATION): BOOLEAN
		do
			Result := conf.is_verbose
		end

	separate_http_server_port (conf: separate HTTP_SERVER_CONFIGURATION): INTEGER
		do
			Result := conf.http_server_port
		end

;note
	copyright: "2011-2011, Javier Velilla and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
