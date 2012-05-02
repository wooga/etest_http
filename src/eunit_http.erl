%% @author Johannes Huning <johannes.huning@wooga.com>
%% @doc Application initialization module.
-module (eunit_http).
-export ([init/0]).
-export ([perform_request/5]).
-include ("eunit_http.hrl").


%% @doc Starts eunit_http, including all dependencies.
init() ->
    Deps = [crypto, public_key, ssl, lhttpc, eunit_http],
    [application:start(Dep) || Dep <- Deps],
    ok.



% TODO - Document!
perform_request(Method, Url, Headers0, Queries, Body) ->
    FullUrl = Url ++ make_query(Queries),

    case lhttpc:request(FullUrl, Method, Headers0, Body, 10000) of
        Error = {error, _} -> Error;
        {ok, Response}     ->
            {{StatusCode, _}, Headers, ResponseBody} = Response,
            #eunit_http_res{
                status_code = StatusCode,
                headers     = Headers,
                body        = ResponseBody
            }
    end.


% TODO - Document!
make_query([]) -> "";

% TODO - Document!
make_query(Queries0) ->
    lists:flatten(["/?" | make_query(Queries0, "")]).


% TODO - Document!
make_query([], Acc) -> Acc;

% TODO - Document!
make_query([{Key, Value}|Rest], Acc) ->
    Query = [edoc_lib:escape_uri(Key), "&", edoc_lib:escape_uri(Value)],
    make_query(Rest, [Query|Acc]).
