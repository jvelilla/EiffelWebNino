note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

deferred class
	HTTP_CONNECTION_POOL

inherit
	SCOOP_POOL [HTTP_CONNECTION_HANDLER]
		rename
			new_separate_item as new_connection_handler,
			release_item as release_connection_handler
		end

feature -- Access

	is_verbose: BOOLEAN
			-- Is using verbose output for logging?

feature -- Change

	set_is_verbose (v: BOOLEAN)
			-- Set `is_verbose' to `v'.
		do
			is_verbose := v
		end

note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
