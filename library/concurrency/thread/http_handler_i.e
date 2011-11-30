note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

deferred class
	HTTP_HANDLER_I

inherit
	THREAD

feature -- Output

	log (m: STRING)
		do
			print (m)
		end

feature -- Daemon

	launch_and_wait
		do
			if force_single_threaded then
				execute
			else
				launch
				join
			end
		end

feature -- Status report

	force_single_threaded: BOOLEAN
		deferred
		end

note
	copyright: "2011-2011, Javier Velilla and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
