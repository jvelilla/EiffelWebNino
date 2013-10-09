note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	HTTP_CONNECTION_POOL

inherit
	CONCURRENT_POOL [HTTP_CONNECTION_HANDLER]
		rename
			release_item as release_connection_handler
		end

create
	make

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
