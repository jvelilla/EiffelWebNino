note
	description: "Summary description for {SHARED_APPLICATION_CONFIGURATION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	SHARED_APPLICATION_CONFIGURATION

feature -- Access

	app_configuration: detachable separate APPLICATION_CONFIGURATION
			-- Shared configuration
		do
			if attached cell_item (app_configuration_cell) as l_cfg then
				Result := l_cfg
			end
		end

	document_root: STRING_8
			-- Shared document root
		do
			if attached app_configuration as l_cfg then
				create Result.make_from_separate (sep_document_root (l_cfg))
			else
				create Result.make_empty
			end
		end

	sep_document_root (cfg: attached like app_configuration): separate STRING_8
		do
			Result := cfg.document_root
		end

feature {SHARED_APPLICATION_CONFIGURATION} -- Element change

	set_app_configuration (a_cfg: APPLICATION_CONFIGURATION)
			-- Set `app_configuration' to `a_cfg'.
		do
			set_app_configuration_cell (app_configuration_cell, a_cfg)
		end

feature {NONE} -- Implementation

	cell_item (cl: like app_configuration_cell): like app_configuration
		do
			Result := cl.item
		end

	set_app_configuration_cell (cl: like app_configuration_cell; a_cfg: APPLICATION_CONFIGURATION)
		do
			cl.replace (a_cfg)
		end

	app_configuration_cell: separate CELL [detachable APPLICATION_CONFIGURATION]
		once ("PROCESS")
			create Result.put (create {APPLICATION_CONFIGURATION}.make) -- dummy value because with Void this crash
		end

note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
