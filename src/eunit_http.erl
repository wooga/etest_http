%% @author Johannes Huning <johannes.huning@wooga.com>
%% @doc Application initialization module.
-module (eunit_http).
-export ([init/0]).
-export ([perform_request/5]).
-include ("eunit_http.hrl").


%% @doc Starts eunit_http, including all dependencies.
init() ->
    Deps = [crypto, public_key, ssl, lhttpc, eunit_http],
    [application:start(Dep) || Dep <- Deps].


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



make_query([H | T]) ->
    "?" ++ [url_var(H) | [["&", url_var(X)] || X <- T]];

make_query([]) ->
    [].

url_var({Key, Value}) ->
    [query_string(Key), "=", query_string(Value)].

query_string( Value ) when is_list(Value) ->
    http_uri:encode(Value);

query_string( Value ) when is_bitstring(Value) ->
    http_uri:encode(binary_to_list(Value));

query_string( Value ) when is_integer(Value) ->
    Value;

% Catch all - throws badarg
query_string( Value ) ->
    throw({badarg, "Argument must be either String, Integer or Bitstring"}).
