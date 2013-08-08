-module (etest_http).
-export ([perform_request/5]).

-include ("etest_http.hrl").

-define(CONTENT_TYPE_FIELD_NAME, 'Content-Type').


% Erlangs built-in HTTP client requires inets to be running to operate.
-on_load (init/0).
init() -> inets:start(), ok.


%% @doc Performs a HTTP request,
%% returning a `etest_http_res` record to assert upon.
perform_request(Method, Url, Headers, Queries, Body) ->
    FullUrl = Url ++ query_string(Queries),
    Request = 
        case Method of
            get    -> {FullUrl, Headers};
            delete -> {FullUrl, Headers};
            post   -> 
                {ok, Type, NewHeaders} = grab_header(?CONTENT_TYPE_FIELD_NAME,
                                                     Headers),
                {FullUrl, NewHeaders, b2s(Type), Body};
            _      -> {FullUrl, Headers, "", Body}
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


%% @doc Generates a query string to be appended to a URL.
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

%% ?perform_post macro allows the following format for header:
%%   header() :: {string() | binary() | atom(), string() | binary()}
%%
%% key should be looked up in different allowed formats, and Headers proplists
%% returned without any reference to the key.
-spec grab_header(atom(), list(term())) -> {'ok', string() | binary(), list(term())}.
grab_header(RawKey, Headers) ->
    case proplists:get_value(RawKey, Headers) of
        undefined ->
            StringKey = atom_to_list(RawKey),
            case proplists:get_value(StringKey, Headers) of
                undefined ->
                    BinaryKey = list_to_binary(atom_to_list(RawKey)),
                    case proplists:get_value(BinaryKey, Headers) of
                        undefined -> {ok, "", Headers};
                        Val -> {ok, Val, proplists:delete(BinaryKey, Headers)}
                    end;
                Val -> {ok, Val, proplists:delete(StringKey, Headers)}
            end;
        Val -> {ok, Val, proplists:delete(RawKey, Headers)}
    end.


%% Makes sure the returned value is a string.
-spec b2s(string() | binary()) -> string().
b2s(Var) when is_binary(Var) ->
    binary_to_list(Var);
b2s(Var) ->
    Var.
