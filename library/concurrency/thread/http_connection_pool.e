note
	description: "Summary description for {HTTP_CONNECTION_POOL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	HTTP_CONNECTION_POOL

inherit
	THREAD_POOL [separate HTTP_CONNECTION_HANDLER]

create
	make

feature -- Access

	add_connection (hdl: separate HTTP_CONNECTION_HANDLER)
		do
			add_work (agent hdl.execute)
		end

note
	copyright: "2011-2012, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
