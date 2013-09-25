note
	description: "Summary description for {HTTP_SERVER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	HTTP_SERVER

create
	make

feature -- Initialization

	make (cfg: HTTP_SERVER_CONFIGURATION)
		do
			configuration := cfg
		end

	setup, launch (a_http_handler: separate HTTP_HANDLER)
		require
			a_http_handler_valid: a_http_handler /= Void
		do
			if is_verbose then
				log ("%N%N%N")
				log ("Starting Web Application Server (port="+ http_server_port.out +"):%N")
			end
			stop_requested := False
			a_http_handler.execute
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

;note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
