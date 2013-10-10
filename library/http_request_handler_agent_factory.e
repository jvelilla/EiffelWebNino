note
	description: "Summary description for {HTTP_REQUEST_HANDLER_FACTORY}."
	date: "$Date$"
	revision: "$Revision$"

class
	HTTP_REQUEST_HANDLER_AGENT_FACTORY [G -> HTTP_REQUEST_HANDLER]

inherit
	HTTP_REQUEST_HANDLER_FACTORY

create
	make

feature {NONE} -- Initialization

	make (agt: like builder_agent)
		do
			builder_agent := agt
		end

feature -- Access

	builder_agent: FUNCTION [ANY, TUPLE, separate G]

feature -- Factory

	new_handler: separate G
		do
			Result := builder_agent.item (Void)
		end

note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
