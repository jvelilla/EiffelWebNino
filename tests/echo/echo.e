class ECHO

--inherit
--	HTTP_SERVER_SHARED_CONFIGURATION

create
	make,
	make_and_launch

feature

	make (p: INTEGER)
		local
			cfg: HTTP_SERVER_CONFIGURATION
		do
			create cfg.make
			setup (cfg, p)
--			set_server_configuration (cfg)

			create server.make (cfg)
			create {TEST_HANDLER} handler.make (server)
		end

	make_and_launch
		do
			make (0)
			launch
		end

feature -- Operation

	launch
		do
			server.launch (handler)
		end

	shutdown
		do
			handler.shutdown
		end

feature -- Access

	is_launched: BOOLEAN
		do
			Result := handler.launched
		end

	port_number: INTEGER
		do
			Result := handler.port
		end

feature {NONE} -- Implementation

	server: HTTP_SERVER

	handler: HTTP_HANDLER

	setup (a_cfg: separate HTTP_SERVER_CONFIGURATION; a_port: INTEGER)
		do
			a_cfg.http_server_port := a_port
--			a_cfg.set_force_single_threaded (True)
--			debug ("nino")
				a_cfg.set_is_verbose (True)
--			end
		end


end
