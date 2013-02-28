%% @author Johannes Huning <johannes.huning@wooga.com>
-module (etest_http).
-export ([perform_request/5]).

-include ("etest_http.hrl").


% Erlangs built-in HTTP client requires inets to be running to operate.
-on_load (init/0).
init() -> inets:start(), ok.


%% @doc Performs a HTTP request,
%% returning a `etest_http_res` record to assert upon.
perform_request(Method, Url, Headers, Queries, Body) ->
    FullUrl = Url ++ query_string(Queries),
    Request = case Method of
        get -> {FullUrl, Headers};
		delete -> {FullUrl, Headers};
        _   -> {FullUrl, Headers, "", Body}
    end,

    case httpc:request(Method, Request, [{autoredirect, false}], []) of
        {ok, Response} ->
            {{_, StatusCode, _}, ResHeaders, ResBody} = Response,
            #etest_http_res {
                status  = StatusCode,
                headers = ResHeaders,
                body    = ResBody };

        Error = {error, _} -> Error
    end.


%% @doc Generates a query string to be appended to ab URL.
query_string([Head|Tail]) ->
    "?" ++ [make_query(Head) | [["&", make_query(Elem)] || Elem <- Tail]];

query_string([]) -> [].

	%% Value to list
make_query({Key, Value}) when
	Value =:= true orelse
	Value =:= false ->
	make_query({Key, atom_to_list(Value)});
make_query({Key, Value}) when is_binary(Value) ->
	make_query({Key, binary_to_list(Value)});
make_query({Key, Value}) when is_integer(Value) ->
	make_query({Key, integer_to_list(Value)});
	%% Key to list
make_query({Key, Value}) when is_atom(Key) ->
	make_query({atom_to_list(Key), Value});
	%% key & value lists
make_query({Key, Value}) when is_list(Key) andalso is_list(Value) ->
    [url_encode(Key), "=", url_encode(Value)].

url_encode(Value) when is_list(Value) ->
    http_uri:encode(Value);

url_encode(Value) when is_bitstring(Value) ->
    url_encode(binary_to_list(Value));

url_encode(Value) when is_integer(Value) ->
    Value.
