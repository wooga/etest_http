%% @author Johannes Huning <johannes.huning@wooga.com>
%% @doc TODO!
-module (eunit_http_tests).
-compile (export_all).
-include_lib ("eunit/include/eunit.hrl").

% TODO - Document!
-include_lib ("eunit_http/include/eunit_http.hrl").


% TODO - Document!
eunit_http_test_()  ->
    {foreach, fun start/0, fun stop/1, [
        fun resAssertions/1, fun jsonAssertions/1
    ]}.

% TODO - Document!
start() ->
    eunit_http:init(),
    ElliArgs = [{callback, eunit_http_handler}, {port, 3002}],
    {ok, Pid} = elli:start_link(ElliArgs),
    Pid.

% TODO - Document!
stop(Pid) ->
    application:stop(eunit_http),
    elli:stop(Pid).


% TODO - Document!
resAssertions(_) ->
    Resps = [?performGet("http://localhost:3002/"),
             ?performPost("http://localhost:3002/")],

    Test = fun(Res) -> [
        ?_assertStatus(Res, 200),
        ?_assertError({assertStatus_failed, _}, ?assertStatus(Res, 400)),

        ?_assertBodyContains(Res, "Hello"),
        ?_assertError({assertContains_failed, _},
            ?assertBodyContains(Res, "Olleh")),

        ?_assertHeader(Res, "Date"),
        ?_assertError({assertHeader_failed, _},
            ?assertHeader(Res, "X-Missing")),

        ?_assertHeaderVal(Res, "Content-Type", "text/html; charset=utf-8"),
        ?_assertError({assertHeaderVal_failed, _},
            ?assertHeaderVal(Res, "Content-Type", "application/json"))]
    end,

    [Test(R) || R <- Resps].


jsonAssertions(_) ->
    Resps = [?performGet("http://localhost:3002/json"),
             ?performPost("http://localhost:3002/json")],

    JsonStruct = orddict:from_list([
        {foo, [bar, baz, 1, 2, 3]},
        {bar, [{baz, bang}]}
    ]),

    Test = fun(Res) -> [
        ?_assertJson(Res, JsonStruct),
        ?_assertError({assertEqual_failed, _}, ?assertJson(Res, [])),

        ?_assertJsonKey(Res, <<"foo">>),
        ?_assertError({assertJsonKey_failed, _}, ?assertJsonKey(Res, "baz")),

        ?_assertJsonVal(Res, <<"foo">>, [<<"bar">>, <<"baz">>, 1, 2, 3]),
        ?_assertJsonVal(Res, [<<"bar">>, <<"baz">>], <<"bang">>),
        ?_assertError({assertJsonVal_failed, _},
            ?assertJsonVal(Res, <<"foo">>, undefined))
        ]
    end,

    [Test(R) || R <- Resps].
