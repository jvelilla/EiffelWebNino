note
	description: "Summary description for {SCOOP_POOLABLE_ITEM}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	SCOOP_POOLABLE_ITEM

feature	{NONE} -- Access

	pool: detachable separate SCOOP_POOL [SCOOP_POOLABLE_ITEM]

feature {SCOOP_POOL} -- Change

	set_pool (p: like pool)
		do
			pool := p
		end

feature {HTTP_HANDLER} -- Basic operation

	release
		do
			if attached pool as p then
				pool_release (p)
			end
		end

feature {NONE} -- Implementation

	pool_release (p: separate SCOOP_POOL [SCOOP_POOLABLE_ITEM])
		do
			p.release_item (Current)
		end

note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
