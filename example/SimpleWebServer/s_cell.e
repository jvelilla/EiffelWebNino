note
	description: "Summary description for {S_CELL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	S_CELL [G]

create
	make

feature

	make (c: separate CELL [G])
		do
			cell := c
		end

feature -- Access

	item: G
		do
			Result := c_item (cell)
		end
			-- Content of cell.

feature -- Element change

	put, replace (v: G)
			-- Make `v' the cell's `item'.
		do
			c_replace (cell, v)
		end

feature {NONE}

	cell: separate CELL [G]

	c_item (c: separate CELL [G]) : G
		do
			Result := c.item
		end

	c_replace (c: separate CELL [G]; v: G)
		do
			c.replace (v)
		end

note
	copyright: "2011-2011, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
