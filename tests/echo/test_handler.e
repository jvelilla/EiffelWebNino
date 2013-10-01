note
	description: "Summary description for {APPLICATION_HANDLER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_HANDLER

inherit
	HTTP_HANDLER

create
	make

feature {NONE} -- Initialization

	build_pool (n: INTEGER)
		do
			create {separate TEST_HTTP_CONNECTION_POOL} pool.make (n)
			initialize_pool (pool, n)
		end

note
	copyright: "2011-2011, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
