%% @author Johannes Huning <johannes.huning@wooga.com>
%% @doc ETest HTTP related assertions.
-ifndef(ETEST_HTTP_HRL).
-define(ETEST_HTTP_HRL, true).


%% @doc The HTTP response record.
%%      Contains all required fields for the assertions to operate on:
%%      Right now that is nothing but status-code, headers and the body.
-record (etest_http_res, {
    status  :: non_neg_integer(),
    headers :: [{binary(), binary() | string()}],
    body    :: binary()
}).


-define (perform_get(Url), ?perform_get(Url, [])).
-define (perform_get(Url, Headers), ?perform_get(Url, Headers, [])).

-define (perform_get(Url, Headers, Queries),
    ?perform_request(get, Url, Headers, Queries, <<>>)).


-define (perform_post(Url), ?perform_post(Url, [])).
-define (perform_post(Url, Headers), ?perform_post(Url, Headers, <<>>)).
-define (perform_post(Url, Headers, Body),
    ?perform_post(Url, Headers, Body, [])).
-define (perform_post(Url, Headers, Body, Queries),
    ?perform_request(post, Url, Headers, Queries, Body)).

-define (perform_put(Url), ?perform_put(Url, [])).
-define (perform_put(Url, Headers), ?perform_put(Url, Headers, <<>>)).
-define (perform_put(Url, Headers, Body),
    ?perform_put(Url, Headers, Body, [])).
-define (perform_put(Url, Headers, Body, Queries),
	?perform_request(put, Url, Headers, Queries, Body)).

-define (perform_delete(Url), ?perform_delete(Url, [])).
-define (perform_delete(Url, Headers), ?perform_delete(Url, Headers, [])).
-define (perform_delete(Url, Headers, Queries),
	?perform_request(delete, Url, Headers, Queries, <<>>)).


-define (perform_request(Method, Url, Headers, Queries, Body),
((fun() ->
    case etest_http:perform_request(Method, Url, Headers, Queries, Body) of
        {error, Reason} ->
            .erlang:error({perform_request,
                [{module, ?MODULE},
                 {line,   ?LINE},
                 {request,
                    {(??Method), (??Url), (??Headers), (??Queries), (??Body)}},
                 {error, Reason}] });
        __Response -> __Response
    end
end)())).


-define (assert_contains(Needle, Haystack),
((fun() ->
    case string:str(Haystack, Needle) of
        0 -> .erlang:error({assert_contains,
                [{module,   ?MODULE},
                 {line,     ?LINE},
                 {haystack, (??Haystack)},
                 {needle,   (??Needle)}] });
        _ -> ok
    end
end)())).

-define (assert_body_contains(Needle, Res),
((fun(__Res) ->
    ?assert_contains(Needle, __Res#etest_http_res.body)
end)(Res))).

-define (assert_body(Body, Res),
((fun(__Res) ->
    ?assert_equal(Body, __Res#etest_http_res.body)
end)(Res))).


-define (assert_header(HeaderName, Res),
((fun(__Res) ->
    Headers = __Res#etest_http_res.headers,
    case proplists:is_defined(HeaderName, Headers) of
        false ->
            .erlang:error({assert_header,
                [{module,   ?MODULE},
                 {line,     ?LINE},
                 {expected, (??HeaderName)},
                 {headers,  Headers}] });
        _ -> ok
    end
end)(Res))).


-define (assert_header_value(HeaderName, HeaderValue0, Res),
((fun(HeaderValue, __Res) ->
    __Headers = __Res#etest_http_res.headers,
    __Name = string:to_lower(HeaderName),
    case proplists:get_value(__Name, __Headers, undefined) of
        HeaderValue -> ok;
        __V -> .erlang:error({assert_header_val,
                    [{module,   ?MODULE},
                     {line,     ?LINE},
                     {header,   (??HeaderName)},
                     {expected, (??HeaderValue0)},
                     {value,    __V}] })
    end
end)(HeaderValue0, Res))).


-define (assert_status(StatusCode0, Res),
((fun(StatusCode, __Res) ->
    case __Res#etest_http_res.status of
        StatusCode -> ok;
        __V -> .erlang:error({assert_status,
                    [{module,   ?MODULE},
                     {line,     ?LINE},
                     {expected, (??StatusCode0)},
                     {value,    __V}] })
    end
end)(StatusCode0, Res))).


-define (assert_json(JsonStruct, Res),
((fun(__Res) ->
    __Value    = etest_http_json:decode(__Res#etest_http_res.body),
    __Expected = etest_http_json:decode(etest_http_json:encode(JsonStruct)),
    ?assert_equal(__Expected, __Value)
end)(Res))).


-define (assert_json_key(Key, Res),
((fun(__Res) ->
    __JsonStruct = etest_http_json:decode(__Res#etest_http_res.body),
    case etest_http_json:fetch(Key, __JsonStruct, '__undefined__') of
        '__undefined__' ->
            .erlang:error({assert_json_key,
                [{module,   ?MODULE},
                 {line,     ?LINE},
                 {expected_expression, (??Key)},
                 {expected_value, Key},
                 {got_value,    undefined}] });
        _ -> ok
    end
end)(Res))).

-define(assert_json_values(__Queries, __Response),
	[?assert_json_value(__K, __V, __Response) || {__K, __V} <- __Queries]).

-define (assert_json_value(Key, Value0, Res),
((fun(Value, __Res) ->
    __JsonStruct = etest_http_json:decode(__Res#etest_http_res.body),
    case etest_http_json:fetch(Key, __JsonStruct, '__undefined__') of
        Value -> ok;
        __V -> .erlang:error({assert_json_val,
                    [{module,   ?MODULE},
                     {line,     ?LINE},
                     {expected_expression, (??Value0)},
                     {expected_value, Value0},
                     {got_value,    __V}] })
    end
end)(Value0, Res))).

-define(get_json_value(__Key, __Response),
((fun
	  (__Key, __JsonStructBin) when is_binary(__JsonStructBin) ->
		 __JsonStruct = etest_http_json:decode(__JsonStructBin),
		 case etest_http_json:fetch(__Key, __JsonStruct, undefined) of
			 undefined -> .erlang:error({json_val_undefined,
										 [{json_struct, __JsonStruct},
										  {module,   ?MODULE},
										  {line,     ?LINE}] });
			 Value -> Value
		 end;

	  (__Key, __Res) ->
		 __JsonStruct = etest_http_json:decode(__Res#etest_http_res.body),
		 case etest_http_json:fetch(__Key, __JsonStruct, undefined) of
			 undefined -> .erlang:error({json_val_undefined,
										 [{module,   ?MODULE},
										  {line,     ?LINE}] });
			 Value -> Value
		 end
 end)(__Key, __Response))).

-endif. % ETEST_HTTP_HRL.
