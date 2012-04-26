-ifndef(EUNIT_HTTP_HRL).
-define(EUNIT_HTTP_HRL, true).

-record (eunit_http_res, {
    status_code,
    headers,
    body,
    json_struct
}).

% TODO - Document!
-define (performGet(Url), ?performGet(Url, [])).

% TODO - Document!
-define (performGet(Url, Headers), ?performGet(Url, Headers, [])).

% TODO - Document!
-define (performGet(Url, Headers, Queries),
    ?performRequest(get, Url, Headers, Queries, <<>>)).


% TODO - Document!
-define (performPost(Url), ?performPost(Url, [])).

% TODO - Document!
-define (performPost(Url, Headers), ?performPost(Url, Headers, <<>>)).

% TODO - Document!
-define (performPost(Url, Headers, Body),
    ?performPost(Url, Headers, Body, [])).

% TODO - Document!
-define (performPost(Url, Headers, Body, Queries),
    ?performRequest(post, Url, Headers, Queries, Body)).


% TODO - Document!
-ifdef(NOASSERT).
-define (performRequest(Method, Url, Headers, Queries, Body), ok).
-else.
-define (performRequest(Method, Url, Headers, Queries, Body),
    erlang:error(not_implemented)).
-endif.


% TODO - Document!
-ifdef(NOASSERT).
-define (assertContains(Haystack, Needle), ok).
-else.
-define (assertContains(Haystack, Needle),
    ((fun() ->
        case string:str(Haystack, Needle) of
            0 -> .erlang:error({assertContains_failed,
                    [{module, ?MODULE},
                     {line, ?LINE},
                     {haystack, (??Haystack)},
                     {needle, (??Needle)}]});
            _ -> ok
        end
    end)())).
-endif.

-define (_assertContains(Haystack, Needle),
    ?_test(?assertContains(Haystack, Needle))).


% TODO - Document!
-ifdef(NOASSERT).
-define (assertBody(Res, Body), ok).
-else.
-define (assertBody(Res, Body),
    erlang:error(not_implemented)).
-endif.

-define (_assertBody(Res, Body), ?_test(assertBody(Res, Body))).



% TODO - Document!
-ifdef(NOASSERT).
-define (assertHeader(Res, HeaderName), ok).
-else.
-define (assertHeader(Res, HeaderName),
    ((fun() ->
        Headers = Res#eunit_http_res.headers,
        case proplists:get_value(HeaderName, Headers, undefined) of
            undefined -> .erlang:error({assertHeader_failed,
                            [{module, ?MODULE},
                             {line, ?LINE},
                             {expected, (??HeaderName)}]});
            _ -> ok
        end
    end)())).
-endif.

-define (_assertHeader(Res, HeaderName), ?_test(assertHeader(Res, HeaderName))).


% TODO - Document!
-ifdef(NOASSERT).
-define (assertHeaderVal(Res, HeaderName, HeaderVal), ok).
-else.
-define (assertHeaderVal(Res, HeaderName, HeaderVal),
    erlang:error(not_implemented)).
-endif.

-define (_assertHeaderVal(Res, HeaderName, HeaderVal),
    ?_test(assertHeaderVal(Res, HeaderName, HeaderVal))).


% TODO - Document!
-ifdef(NOASSERT).
-define (assertStatus(Res, StatusCode), ok).
-else.
-define (assertStatus(Res, StatusCode),
    erlang:error(not_implemented)).
-endif.

-define (_assertStatus(Res, StatusCode), ?_test(assertStatus(Res, StatusCode))).


% TODO - Document!
-ifdef(NOASSERT).
-define (assertJson(Res), ok).
-else.
-define (assertJson(Res),
    erlang:error(not_implemented)).
-endif.

-define (_assertJson(Res), ?_test(assertJson(Res))).


% TODO - Document!
-ifdef(NOASSERT).
-define (assertJson(Res, JsonStruct), ok).
-else.
-define (assertJson(Res, JsonStruct),
    erlang:error(not_implemented)).
-endif.

-define (_assertJson(Res, JsonStruct), ?_test(assertJson(Res, JsonStruct))).


% TODO - Document!
-ifdef(NOASSERT).
-define (assertJsonKey(Res, Key), ok).
-else.
-define (assertJsonKey(Res, Key),
    erlang:error(not_implemented)).
-endif.

-define (_assertJsonKey(Res, Key), ?_test(assertJsonKey(Res, Key))).


% TODO - Document!
-ifdef(NOASSERT).
-define (assertJsonVal(Res, Key, Val), ok).
-else.
-define (assertJsonVal(Res, Key, Val),
    erlang:error(not_implemented)).
-endif.

-define (_assertJsonVal(Res, Key, Val), ?_test(assertJsonVal(Res, Key, Val))).


-endif.
