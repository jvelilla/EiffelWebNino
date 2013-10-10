class ECHO

create
	make,
	make_and_launch

feature {NONE} -- Initialization

	make (p: INTEGER)
		local
			cfg: HTTP_SERVER_CONFIGURATION
			l_factory: TEST_CONNECTION_HANDLER_FACTORY
		do
			create cfg.make
			setup (cfg, p)

			create l_factory
			create server.make (cfg, l_factory)

--			if attached (create {PLAIN_TEXT_FILE}.make_with_name ("server.log")) as f then
--				f.open_append
--				server.set_log_output (f)
--				log_output := f		
--			end

			l_factory.set_server (server) -- to provide shutdown facility to TEST_CONNECTION_HANDLER
		end

	make_and_launch
		do
--			make (0)
			make (9090)
			launch
		end

feature -- Operation

	launch
		do
			server.launch
			on_terminated
		end

	on_terminated
		do
			if attached log_output as f and then not f.is_closed then
				f.flush
				f.close
			end
		end

feature -- Access

	log_output: detachable FILE
			-- Optional log output file.

	is_launched: BOOLEAN
		do
			Result := separate_is_launched (listener)
		end

	port_number: INTEGER
		do
			Result := separate_port_number (listener)
		end

feature {NONE} -- Implementation

	separate_port_number (h: like listener): INTEGER
		do
			Result := h.port
		end

	separate_is_launched (h: like listener): BOOLEAN
		do
			Result := h.is_launched
		end

	separate_is_terminated (h: like listener): BOOLEAN
		do
			Result := h.is_terminated
		end

	server: HTTP_SERVER

	listener: HTTP_SERVER
		do
			Result := server
		end

	setup (a_cfg: HTTP_SERVER_CONFIGURATION; a_port: INTEGER)
		do
			a_cfg.http_server_port := a_port
			a_cfg.set_max_concurrent_connections (500)
			debug ("nino")
				a_cfg.set_is_verbose (True)
			end
		end

end
