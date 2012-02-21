note
	description: "[
		Eiffel tests that can be executed by testing tool.
	]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	TEST_REQUEST

inherit
	EQA_TEST_SET
		redefine
			on_prepare,
			on_clean
		end

feature {NONE} -- Events

	echo_server: detachable ECHO

	port_number: INTEGER
	base_url: detachable STRING

	on_prepare
			-- <Precursor>
		local
			echo: ECHO
			e: EXECUTION_ENVIRONMENT
		do
			create error_message.make_empty

			if server_inside then
				create echo.make (9999)
				echo_server := echo
				echo.launch

				create e
				from

				until
					echo.is_launched
				loop
					e.sleep (1_000_000) -- 1 ms
				end

				port_number := echo.port_number
			else
				create e
				e.sleep (1_000_000_000 * 5)
				port_number := 64757
			end
		end

	server_inside: BOOLEAN = False --| CHANGE HERE TO USE EITHER in same process or in other process ... to be improved

	on_clean
			-- <Precursor>
		do
			if attached echo_server as server then
				server.shutdown
			end
		end

	http_session: detachable HTTP_CLIENT_SESSION

	get_http_session
		do
			http_session := new_http_session
		end

	new_http_session: HTTP_CLIENT_SESSION
		local
			h: LIBCURL_HTTP_CLIENT
			b: like base_url
		do
			create h.make
			b := base_url
			if b = Void then
				b := ""
			end
			Result := h.new_session ("localhost:" + port_number.out + "/" + b)
			Result.set_timeout (-1)
			Result.set_connect_timeout (-1)
		end

	impl_test_get_request (a_url: READABLE_STRING_8; ctx: detachable HTTP_CLIENT_REQUEST_CONTEXT; a_expected_body: READABLE_STRING_8; a_substring: detachable READABLE_STRING_8; a_reuse_session: BOOLEAN): detachable STRING_8
		local
			sess: like http_session
		do
			if a_reuse_session then
				get_http_session
				sess := http_session
			end

			if sess = Void then
				sess := new_http_session
			end
			if sess /= Void then
				if attached sess.get (a_url, adapted_context (ctx)) as res and then not res.error_occurred and then attached res.body as l_body then
					io.put_string ("%N" + l_body + "%N")
					if not l_body.starts_with (a_expected_body) then
						Result := "Not expected answer got=%""+l_body+"%" expected=%""+a_expected_body+"%" url=" + sess.base_url + a_url
					elseif a_substring /= Void and then l_body.substring_index (a_substring, 1) = 0 then
						Result := "Missing substring %""+a_substring+"%" in %""+l_body+"%" url=" + sess.base_url + a_url

					end
				else
					Result := "Request %""+a_url+"%" failed"
				end
			end
		end

	impl_test_post_request (a_url: READABLE_STRING_8; ctx: detachable HTTP_CLIENT_REQUEST_CONTEXT; a_expected_body: READABLE_STRING_8; a_reuse_session: BOOLEAN)
		local
			sess: like http_session
		do
			if a_reuse_session then
				get_http_session
				sess := http_session
			end

			if sess = Void then
				sess := new_http_session
			end
			if sess /= Void then
				if attached sess.post (a_url, adapted_context (ctx), Void) as res and then not res.error_occurred and then attached res.body as l_body then
					assert ("Good answer got=%""+l_body+"%" expected=%""+a_expected_body+"%"", l_body.same_string (a_expected_body))
				else
					assert ("Request %""+a_url+"%" failed", False)
				end
			end
		end

	adapted_context (ctx: detachable HTTP_CLIENT_REQUEST_CONTEXT): HTTP_CLIENT_REQUEST_CONTEXT
		do
			if ctx /= Void then
				Result := ctx
			else
				create Result.make
			end
--			Result.set_proxy ("127.0.0.1", 8888) --| inspect traffic with http://www.fiddler2.com/			
		end

	test_get_request (a_reuse_session: BOOLEAN)
			-- New test routine
		local
			ctx: detachable HTTP_CLIENT_REQUEST_CONTEXT
			s: detachable READABLE_STRING_8
			n: INTEGER
			m: STRING_8
		do
			create m.make_empty
			create ctx.make
			ctx.headers.force ("Bar", "Foo")
			s := impl_test_get_request ("get/01", ctx, "Request GET /get/01", "Foo=Bar", a_reuse_session)-- Host=localhost:"+port_number.out+" Accept=*/*", a_reuse_session)
			if s = Void then
				n := n + 1
			else
				m.append (s)
				m.append_character ('%N')
			end

			if n = 1 then
				-- Ok
				succeed_count := succeed_count + 1
			else
				error_message.append (m)
			end
		end

	succeed_count: INTEGER

	error_message: STRING

	reset_test
		do
			succeed_count := 0
			error_message := ""
		end

	check_succeed (n: INTEGER)
		do
			assert ("succeed count ok: " + succeed_count.out + error_message, succeed_count = n)
		end

feature -- Test routines

	test_get_one_request
		do
			reset_test
			test_get_request (True)
			check_succeed (1)
		end

	test_get_n_sequential
		do
			reset_test
			test_get_sequential (10, agent test_get_request (True))
			check_succeed (10)
		end

	test_get_n_sequential_thread
		do
			reset_test
			test_get_sequential_thread (10, agent test_get_request (False))
			check_succeed (10)
		end

	test_get_n_concurrent
		do
			reset_test
			test_get_concurrent (1000, agent test_get_request (False))
			check_succeed (1000)
		end

feature {NONE} -- Implementation

	test_get_sequential (n: INTEGER; agt: PROCEDURE [ANY, TUPLE])
		do
			io.error.put_string ("Launch "+ n.out +" requests%N")
			across 1 |..| n as c loop
				agt.call (Void)
			end
		end

	test_get_sequential_thread (n: INTEGER; agt: PROCEDURE [ANY, TUPLE])
		local
			wt: WORKER_THREAD
			wt_list: ARRAYED_LIST [WORKER_THREAD]
		do
			create wt_list.make (n)
			io.error.put_string ("Build workers%N")
			across 1 |..| n as c loop
				create wt.make (agt)
				wt_list.extend (wt)
			end

			io.error.put_string ("Launch workers and wait for each one%N")
			across
				wt_list as c
			loop
				c.item.launch
				c.item.join
			end
		end

	test_get_concurrent (n: INTEGER; agt: PROCEDURE [ANY, TUPLE])
		local
			wt: WORKER_THREAD
			wt_list: ARRAYED_LIST [WORKER_THREAD]
		do
			create wt_list.make (n)
			io.error.put_string ("Build workers%N")
			across 1 |..| n as c loop
				create wt.make (agt)
				wt_list.extend (wt)
			end

			io.error.put_string ("Launch workers%N")
			across
				wt_list as c
			loop
				c.item.launch
			end

			io.error.put_string ("Wait workers%N")
			from
				wt_list.start
			until
				wt_list.is_empty or wt_list.after
			loop
				across
					wt_list as c
				loop
					if c.item.join_with_timeout (10) then
						wt_list.prune (c.item)
					end
				end
				wt_list.start
			end
		end

end


