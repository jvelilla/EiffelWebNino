note
	description: "Summary description for {HTTP_SERVER_SHARED_CONFIGURATION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	HTTP_SERVER_SHARED_CONFIGURATION

feature -- Access

	server_configuration: detachable separate HTTP_SERVER_CONFIGURATION
			-- Shared configuration
		do
			if attached cell_item (server_configuration_cell) as l_cfg then
				Result := l_cfg
			end
		end

	document_root: separate STRING_8
			-- Shared document root
		do
			if attached server_configuration as l_cfg then
				Result := sep_document_root (l_cfg)
			else
				Result := ""
			end
		end

	sep_document_root (cfg: attached like server_configuration): separate STRING_8
		do
			Result := cfg.document_root
		end

feature -- Element change

	set_server_configuration (a_cfg: like server_configuration)
			-- Set `server_configuration' to `a_cfg'.
		do
			set_server_configuration_cell (server_configuration_cell, a_cfg)
		end

feature {NONE} -- Implementation

	cell_item (cl: like server_configuration_cell): like server_configuration
		do
			Result := cl.item
		end

	set_server_configuration_cell (cl: like server_configuration_cell; a_cfg: like server_configuration)
		do
			cl.replace (a_cfg)
		end

	server_configuration_cell: separate CELL [detachable separate HTTP_SERVER_CONFIGURATION]
		do --("PROCESS")
			create Result.put (Void)
		end

note
	copyright: "2011-2011, Javier Velilla and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
