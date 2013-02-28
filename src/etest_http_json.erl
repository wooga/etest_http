%% @doc JSON specific helper functions.
-module (etest_http_json).

%% Public helper methods.
-export ([encode/1, decode/1, fetch/2, fetch/3, construct/1]).


% Insert a new element to the JSON-object.
store(Json, Key, Value) ->
    % Note that orddict:store inserts elements sorted.
    orddict:store(Key, Value, Json).


% Create a new JSON-struct in the underlying representation.
create() ->
    % For orddict, this would be the empty list: [].
    orddict:new().


% @doc Construct a new JSON struct from the given proplist.
construct(Proplist = [{_,_}|_]) ->
    Step = fun({Key, Value}, Json) ->
        store(Json, Key, construct(Value))
    end,
    lists:foldl(Step, create(), Proplist);

% For all other elements which are not proplists, return their identity; only
% proplists need recursive folding to ensure order in the underlying orddict.
construct(Literal) -> Literal.


%% @doc TODO.
fetch([Key|[]], Orddict) ->
    fetch(Key, Orddict);

fetch([Parent|Rest], Orddict) ->
    fetch(Rest, fetch(Parent, Orddict));

fetch(Key, Orddict) when is_atom(Key) ->
    fetch(atom_to_binary(Key, latin1), Orddict);

fetch(Key, Orddict) ->
    orddict:fetch(Key, Orddict).


%% @doc Attempt to fetch the fiven Key from the Orddict or return the Default.
fetch(Key, Dict, Default) ->
    case (catch fetch(Key, Dict)) of
        {'EXIT', _} -> Default;
        Value       -> Value
    end.


% TODO - Document!
encode(Orddict) ->
    jiffy:encode(pack(Orddict)).

% TODO - Document!
decode(Binary) ->
    construct(unpack(jiffy:decode(Binary))).


%% @doc Attempts to extract a orddict from the given jiffy-JSON.
unpack(Json) when is_list(Json) orelse is_tuple(Json) ->
    unpack(Json, orddict:new());

%% Only tuples and list require deeper unpacking, return simple structs.
unpack(Json) -> Json.

%% @doc Recursively unpacks a nested jiffy-JSON object.
unpack({Proplist}, Dict) when is_list(Proplist) ->
    lists:foldl(
        fun({Key, Value}, Acc) ->
            orddict:store(Key, unpack(Value), Acc)
        end,
        Dict,
        Proplist
    );

% List of jiffy-JSON => list of unpacked structs.
unpack(List, _) when is_list(List) ->
    [unpack(Elem) || Elem <- List].

%% @doc Recursively builds a jiffy-JSON struct from the given orddict.
% Single orddict => jiffy-JSON object.
pack(Orddict = [Head|_]) when is_list(Orddict) andalso is_tuple(Head) ->
    {orddict:fold(
        fun(Key, Value, Acc) ->
            Acc ++ [{Key, pack(Value)}]
        end,
        [],
        Orddict
    )};

% Treat the empty list as an empty object.
pack([]) -> {[]};

% List of orddicts => list of jiffy-JSON objects.
pack(List) when is_list(List) ->
    [pack(Elem) || Elem <- List];

pack(undefined) -> null;

% Simple term => same simple term.
pack(Value) -> Value.
