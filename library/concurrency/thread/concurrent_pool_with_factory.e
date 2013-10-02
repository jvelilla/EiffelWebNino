note
	description: "[
			Objects that ...
		]"
	author: "$Author$"
	date: "$Date$"
	revision: "$Revision$"

class
	CONCURRENT_POOL_WITH_FACTORY [G -> CONCURRENT_POOL_ITEM]

inherit
	CONCURRENT_POOL [G]
		rename
			make as old_make
		end

create
	make

feature {NONE} -- Initialization

	make (n: INTEGER; f: like factory)
			-- Initialize `Current'.
		do
			old_make (n)
			set_factory (f)
		end

feature -- Access

	factory: separate CONCURRENT_POOL_FACTORY [G]

	factory_new_separate_item (f: like factory): like new_separate_item
		do
			Result := f.new_separate_item
		end

	new_separate_item: separate G
		do
			Result := factory_new_separate_item (factory)
		end

feature -- Change

	set_factory (f: like factory)
		do
			factory := f
		end

note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
