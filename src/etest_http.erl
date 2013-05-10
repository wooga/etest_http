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
    Hdrs = normalise_headers(Headers),
    Request = case Method of
        get -> {FullUrl, Hdrs};
        delete -> {FullUrl, Hdrs};
        _   -> {FullUrl, Hdrs, content_type(Hdrs), Body}
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


%% @doc Normalises headers - binary/string/atom -> string.
normalise_headers(Headers) ->
    [{norm_k(Key), norm_v(Value)} || {Key, Value} <- Headers].


%% @doc Normalises headers and extracts content-type.
content_type(Headers) ->
    proplists:get_value("content-type",
                        Headers,
                        "application/x-www-form-urlencoded").


%% @doc Reformat all header keys to lowercase strings.
norm_k(K) when is_binary(K) -> norm_k(binary_to_list(K));
norm_k(K) when is_list(K) -> string:to_lower(K);
norm_k(K) when is_atom(K) -> atom_to_list(K).


%% @doc Reformat all header values to strings.
norm_v(V) when is_binary(V) -> norm_k(binary_to_list(V));
norm_v(V) when is_atom(V) -> atom_to_list(V);
norm_v(V) -> V.


%% @doc Generates a query string to be appended to ab URL.
query_string([Head|Tail]) ->
    "?" ++ [make_query(Head) | [["&", make_query(Elem)] || Elem <- Tail]];

query_string([]) -> [].

% Value to list
make_query({Key, Value}) when
    Value =:= true orelse
    Value =:= false ->
    make_query({Key, atom_to_list(Value)});

make_query({Key, Value}) when is_binary(Value) ->
    make_query({Key, binary_to_list(Value)});

make_query({Key, Value}) when is_integer(Value) ->
    make_query({Key, integer_to_list(Value)});

% Key to list
make_query({Key, Value}) when is_atom(Key) ->
    make_query({atom_to_list(Key), Value});

make_query({Key, Value}) ->
    [url_encode(Key), "=", url_encode(Value)].


url_encode(Value) when is_list(Value) ->
    http_uri:encode(Value);

url_encode(Value) when is_bitstring(Value) ->
    url_encode(binary_to_list(Value));

url_encode(Value) when is_integer(Value) ->
    Value.
