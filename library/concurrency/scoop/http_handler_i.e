note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

deferred class
	HTTP_HANDLER_I

inherit
	ANY

feature -- Output

	log (m: STRING)
		do
			io.put_string (m)
		end

feature -- Daemon

	launch_and_wait
		do
			execute
		end

feature -- Execution

	execute
		deferred
		end

note
	copyright: "2011-2011, Javier Velilla and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
