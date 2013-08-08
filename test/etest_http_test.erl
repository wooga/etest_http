%% @author Johannes Huning <johannes.huning@wooga.com>
%% @doc Test of the assertions itself.
-module(etest_http_test).
-compile(export_all).

-include_lib("etest/include/etest.hrl").
-include_lib("etest_http/include/etest_http.hrl").

before_suite() ->
    inets:start(),
    {ok, Pid} = inets:start(httpd, 
                            [
                             {port, 59408},
                             {server_name,   "etest_httpd"},
                             {server_root,   "/tmp"},
                             {ipfamily,      inet},
                             {document_root, "priv"} 
                            ]),
    put(server_pid, Pid).


after_suite() ->
    ok = inets:stop(httpd, get(server_pid)).


test_response_assertions() ->
    Res = ?perform_get("http://localhost:59408/first.html"),
    
    ?assert_status(200, Res),
    ?assert_error({assert_status, _}, ?assert_status(400, Res)),
    ?assert_body_contains("Hello", Res),
    ?assert_body_not_contains("Olleh", Res),
    
    ?assert_error({assert_contains, _}, ?assert_body_contains("Olleh", Res)),
    
    ?assert_header("date", Res),
    ?assert_error({assert_header, _}, ?assert_header("X-Missing", Res)),
    
    ?assert_header_value("content-type", "text/html", Res),
    ?assert_error({assert_header_val, _},
                  ?assert_header_value("content-type", "application/json", Res)).


test_json_assertions() ->
    JsonStruct = etest_http_json:construct([
                                            {foo, [bar, baz, 1, 2, 3]},
                                            {bar, [{baz, bang}]}
                                           ]),

    Res = ?perform_get("http://localhost:59408/second.json"),
    
    ?assert_json(JsonStruct, Res),
    ?assert_error({assert_equal, _}, ?assert_json([], Res)),
    
    ?assert_json_key(<<"foo">>, Res),
    ?assert_error({assert_json_key, _}, ?assert_json_key("baz", Res)),
    
    ?assert_json_value(<<"foo">>, [<<"bar">>, <<"baz">>, 1, 2, 3], Res),
    ?assert_json_value([<<"bar">>, <<"baz">>], <<"bang">>, Res),
    ?assert_error({assert_json_val, _},
                  ?assert_json_value(<<"foo">>, undefined, Res)).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

post_with_string_content_type_test() ->
    ContentType = "application/foo",
    meck:new(httpc),
    meck:expect(httpc, request, fun(post, {_, _, Type, _}, _, []) when Type == ContentType ->
                                        {ok, {{a,b,c},d,e}};
                                   (_, {_ , _, _, _}, _, _) ->
                                        {error, bad_header}
                                end),
    URL = "http:localhost:8888/index.html",
    Headers = [{"Content-Type", ContentType}],
    Body = <<"{\"name\":\"value\"}">>,
    ?assertMatch(#etest_http_res{}, etest_http:perform_request(post, URL, Headers, [], Body)),
    meck:unload(httpc).

post_with_binary_content_type_test() ->
    ContentType = "application/foo",
    meck:new(httpc),
    meck:expect(httpc, request, fun(post, {_, _, Type, _}, _, []) when Type == ContentType ->
                                        {ok, {{a,b,c},d,e}};
                                   (_, _, _, _) ->
                                        {error, bad_header}
                                end),
    URL = "http:localhost:8888/index.html",
    Headers = [{<<"Content-Type">>, ContentType}],
    Body = <<"{\"name\":\"value\"}">>,
    ?assertMatch(#etest_http_res{}, etest_http:perform_request(post, URL, Headers, [], Body)),
    meck:unload(httpc).
    
-endif.
