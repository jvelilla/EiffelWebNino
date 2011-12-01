note
	description : "nino application root class"
	date        : "$Date$"
	revision    : "$Revision$"

class
	APPLICATION

inherit
	ARGUMENTS

	HTTP_SERVER_SHARED_CONFIGURATION

create
	make

feature {NONE} -- Initialization

	make
			-- Run application.
		local
			l_server: HTTP_SERVER
			l_cfg: separate HTTP_SERVER_CONFIGURATION
			l_http_handler: HTTP_HANDLER
		do
			create l_cfg.make
			setup (l_cfg)
			set_server_configuration (l_cfg)

			create l_server.make (l_cfg)
			create {APPLICATION_HANDLER} l_http_handler.make (l_server)
			l_server.setup (l_http_handler)
		end

	setup (a_cfg: separate HTTP_SERVER_CONFIGURATION)
		do
			a_cfg.http_server_port := 9_000
			a_cfg.document_root := default_document_root
			debug ("nino")
				a_cfg.set_is_verbose (True)
			end
		end

feature -- Access

	default_document_root: STRING = "webroot"

note
	copyright: "2011-2011, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end

