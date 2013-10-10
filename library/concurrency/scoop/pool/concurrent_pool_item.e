note
	description: "Summary description for {CONCURRENT_POOL_ITEM}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	CONCURRENT_POOL_ITEM

feature	{NONE} -- Access

	pool: detachable separate CONCURRENT_POOL [CONCURRENT_POOL_ITEM]

feature {CONCURRENT_POOL} -- Change

	set_pool (p: like pool)
		do
			pool := p
		end

feature {CONCURRENT_POOL, HTTP_CONNECTION_HANDLER_I} -- Basic operation

	release
		do
			if attached pool as p then
				pool_release (p)
			end
		end

feature {NONE} -- Implementation

	pool_release (p: separate CONCURRENT_POOL [CONCURRENT_POOL_ITEM])
		do
			p.release_item (Current)
		end

note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
