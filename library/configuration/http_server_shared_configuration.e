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
			if attached server_configuration_cell.item as l_cfg then
				Result := l_cfg
			end
		end

	document_root: STRING_8
			-- Shared document root
		do
			if attached server_configuration as l_cfg then
				Result := str_cp (cfg_document_root (l_cfg))
			else
				Result := ""
			end
		end

feature -- Element change

	set_server_configuration (a_cfg: like server_configuration)
			-- Set `server_configuration' to `a_cfg'.
		do
			server_configuration_cell.replace (a_cfg)
		end

feature {NONE} -- Implementation

	s_c_c: separate CELL [detachable separate HTTP_SERVER_CONFIGURATION]
		once ("PROCESS")
			create Result.put (Void)
		end

	server_configuration_cell: S_CELL [detachable separate HTTP_SERVER_CONFIGURATION]
		once
			create Result.make (s_c_c)
		end

	cfg_document_root (l_cfg: attached separate HTTP_SERVER_CONFIGURATION): separate STRING_8
		do
			Result := l_cfg.document_root
		end

	str_cp (s: separate STRING_8): STRING_8
		local
			i: INTEGER
		do
			from
				create Result.make_empty
				i := 1
			until
				i > s.count
			loop
				Result.append_character (s [i])
				i := i + 1
			end
		end

note
	copyright: "2011-2011, Javier Velilla and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
