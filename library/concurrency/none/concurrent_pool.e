note
	description: "Summary description for {CONCURRENT_POOL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	CONCURRENT_POOL [G -> CONCURRENT_POOL_ITEM]

feature {NONE} -- Initialization

	make (n: INTEGER)
		do
		end

feature -- Access

	is_full: BOOLEAN
		do
			Result := False
		end

	stop_requested: BOOLEAN

feature -- Access

	separate_item: detachable separate G
		do
			if not stop_requested then
				Result := new_separate_item
			end
		end

feature -- Basic operation

	gracefull_stop
		do
			stop_requested := True
		end

feature {CONCURRENT_POOL_ITEM} -- Change

	release_item (a_item: like new_separate_item)
			-- Unregister `a_item' from Current pool.
		do
		end

feature -- Change

	set_count (n: INTEGER)
		do
		end

feature {NONE} -- Implementation

	new_separate_item: separate G
		deferred
		end

	register_item (a_item: like new_separate_item)
		do
		end

note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
