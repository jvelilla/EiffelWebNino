class ECHO

create
	make,
	make_and_launch

feature

	make (p: INTEGER)
		local
			cfg: HTTP_SERVER_CONFIGURATION
			f: PLAIN_TEXT_FILE
		do
			create cfg.make
			setup (cfg, p)

			create server.make (cfg)

			create f.make_with_name ("server.log")
			f.open_append
			server.set_log_output (f)
			log_output := f

			create {TEST_HANDLER} handler.make (server)
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
			server.launch (handler)
			on_terminated
		end

	shutdown
		do
			separate_shutdown (handler)
		end

	on_terminated
		do
			if attached log_output as f then
				f.flush
				f.close
			end
		end

feature -- Access

	log_output: detachable FILE
			-- Optional log output file.

	is_launched: BOOLEAN
		do
			Result := separate_is_launched (handler)
		end

	port_number: INTEGER
		do
			Result := separate_port_number (handler)
		end

feature {NONE} -- Implementation

	separate_shutdown (h: like handler)
		do
			h.shutdown
		end

	separate_port_number (h: like handler): INTEGER
		do
			Result := h.port
		end

	separate_is_launched (h: like handler): BOOLEAN
		do
			Result := h.launched
		end

	server: HTTP_SERVER

	handler: HTTP_HANDLER

	setup (a_cfg: HTTP_SERVER_CONFIGURATION; a_port: INTEGER)
		do
			a_cfg.http_server_port := a_port
			a_cfg.set_max_concurrent_connections (50)
			debug ("nino")
				a_cfg.set_is_verbose (True)
			end

			a_cfg.set_is_verbose (True)
		end


end
