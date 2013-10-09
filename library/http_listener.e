note
	description: "Summary description for {HTTP_LISTENER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	HTTP_LISTENER

inherit
	HTTP_LISTENER_I

create
	make

feature {NONE} -- Initialization

	build_engine
		do
			create {HTTP_ACCEPTER} engine.make (server)
		end

note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
