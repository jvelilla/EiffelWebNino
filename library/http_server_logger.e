note
	description: "Summary description for {HTTP_SERVER_LOGGER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	HTTP_SERVER_LOGGER

feature -- Logs

	log (a_message: separate READABLE_STRING_8)
			-- Log `a_message'
		deferred
		end

note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
