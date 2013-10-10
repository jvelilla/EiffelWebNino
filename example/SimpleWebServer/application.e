note
	description : "nino application root class"
	date        : "$Date$"
	revision    : "$Revision$"

class
	APPLICATION

inherit
	ARGUMENTS

	SHARED_APPLICATION_CONFIGURATION

create
	make

feature {NONE} -- Initialization

	make_with_port (a_port: INTEGER)
			-- Run application.
		local
			app_cfg: APPLICATION_CONFIGURATION
			l_cfg: HTTP_SERVER_CONFIGURATION
		do
			create app_cfg.make
			app_cfg.set_document_root (default_document_root)
			set_app_configuration (app_cfg)

			create l_cfg.make
			setup (l_cfg, a_port)

			create server.make (l_cfg, create {separate APPLICATION_FACTORY})
		end

	make
		do
			make_with_port (9090)
			launch
		end

	launch
		do
			server.launch
		end

	setup (a_cfg: HTTP_SERVER_CONFIGURATION; a_port: INTEGER)
		do
			a_cfg.http_server_port := a_port
			a_cfg.set_max_concurrent_connections (50)
			debug ("nino")
				a_cfg.set_is_verbose (True)
			end
			a_cfg.set_is_verbose (True)
		end

feature -- Access

	server: HTTP_SERVER

	default_document_root: STRING = "webroot"

note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end

