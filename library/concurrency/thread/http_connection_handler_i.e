note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

deferred class
	HTTP_CONNECTION_HANDLER_I

inherit
	THREAD
		rename
			make as thread_make
		end

feature {NONE} -- Initialization

	make (a_is_verbose: BOOLEAN)
		do
			thread_make
		end

note
	copyright: "2011-2012, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
