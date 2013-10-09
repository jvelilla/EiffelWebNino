note
	description: "Summary description for {HTTP_CONNECTION_HANDLER_FACTORY_I}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	HTTP_CONNECTION_HANDLER_FACTORY_I

feature -- Factory

	new_handler: separate HTTP_CONNECTION_HANDLER
		deferred
		end

note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
