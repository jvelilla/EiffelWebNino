note
	description: "Summary description for {HTTP_DEBUG_FACILITIES}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	HTTP_DEBUG_FACILITIES

feature {NONE} -- Output

	dbglog (m: READABLE_STRING_8)
		require
			not m.ends_with_general ("%N")
		do
			debug ("dbglog")
				print ("[" + processor_id_from_object (Current).out + "] " + m + "%N")
			end
		end

feature -- runtime

	frozen processor_id_from_object (a_object: separate ANY): INTEGER_32
		external
			"C inline use %"eif_scoop.h%""
		alias
			"RTS_PID(eif_access($a_object))"
		end

note
	copyright: "2011-2013, Javier Velilla, Jocelyn Fiat and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
