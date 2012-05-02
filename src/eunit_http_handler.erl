%% @author Johannes Huning <johannes.huning@wooga.com>
%% @doc TODO!
-module (eunit_http_handler).
-behaviour (elli_handler).
-export ([handle/2, handle_event/3]).

% TODO - Document!
-define (HEADERS, [
    {<<"Date">>,         <<"Wed, 02 May 2012 13:03:14 GMT">>},
    {<<"Content-Type">>, <<"text/html; charset=utf-8">>} ]).


% TODO - Document!
handle(Req, Args) ->
    handle(elli_request:path(Req), Req, Args).


% TODO - Document!
handle([<<"json">>], _Req, _Args) ->
    JsonStruct = orddict:from_list([
        {foo, [bar, baz, 1, 2, 3]},
        {bar, [
            {baz, bang}
        ]}
    ]),
    {200, ?HEADERS, eunit_http_json:encode(JsonStruct)};

% TODO - Document!
handle(_, _Req, _Args) -> {200, ?HEADERS, <<"Hello">>}.


% TODO - Document!
handle_event(_Event, _Data, _Args) -> ok.
