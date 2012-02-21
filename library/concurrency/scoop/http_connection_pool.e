note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	HTTP_CONNECTION_POOL

create
	make

feature {NONE} -- Initialization

--	list: ARRAYED_LIST [detachable separate HTTP_CONNECTION_HANDLER]

	make (n: INTEGER)
			-- Initialize `Current'.
		do
--			create list.make (n)
		end

feature -- Change

	add_connection (h: separate HTTP_CONNECTION_HANDLER)
		do
--			list.extend (h)
			h.receive_message_and_send_reply (False)
		end

end
