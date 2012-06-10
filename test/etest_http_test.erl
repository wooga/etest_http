%% @author Johannes Huning <johannes.huning@wooga.com>
%% @doc Test of the assertions itself.
-module (etest_http_test).
-compile (export_all).

-include_lib ("etest/include/etest.hrl").
-include_lib ("etest_http/include/etest_http.hrl").


before_suite() ->
    inets:start(),
    {ok, Pid} = inets:start(httpd, [
        {port, 59408},
        {server_name,   "etest_httpd"},
        {server_root,   "/tmp"},
        {ipfamily,      inet},
        {document_root, "priv"} ]),
    put(server_pid, Pid).


after_suite() ->
    ok = inets:stop(httpd, get(server_pid)).


test_response_assertions() ->
    Res = ?perform_get("http://localhost:59408/first.html"),

    ?assert_status(Res, 200),
    ?assert_error({assert_status, _}, ?assert_status(Res, 400)),

    ?assert_body_contains(Res, "Hello"),
    ?assert_error({assert_contains, _}, ?assert_body_contains(Res, "Olleh")),

    ?assert_header(Res, "date"),
    ?assert_error({assert_header, _}, ?assert_header(Res, "X-Missing")),

    ?assert_header_val(Res, "content-type", "text/html"),
    ?assert_error({assert_header_val, _},
        ?assert_header_val(Res, "content-type", "application/json")).


test_json_assertions() ->
    JsonStruct = etest_http_json:construct([
        {foo, [bar, baz, 1, 2, 3]},
        {bar, [{baz, bang}]}
    ]),

    Res = ?perform_get("http://localhost:59408/second.json"),

    ?assert_json(Res, JsonStruct),
    ?assert_error({assert_equal, _}, ?assert_json(Res, [])),

    ?assert_json_key(Res, <<"foo">>),
    ?assert_error({assert_json_key, _}, ?assert_json_key(Res, "baz")),

    ?assert_json_val(Res, <<"foo">>, [<<"bar">>, <<"baz">>, 1, 2, 3]),
    ?assert_json_val(Res, [<<"bar">>, <<"baz">>], <<"bang">>),
    ?assert_error({assert_json_val, _},
        ?assert_json_val(Res, <<"foo">>, undefined)).
