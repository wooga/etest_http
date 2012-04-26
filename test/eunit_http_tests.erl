-module (eunit_http_tests).
-include_lib ("eunit/include/eunit.hrl").

-include_lib ("eunit_http/include/eunit_http.hrl").
-export ([init/0]).
-on_load (init/0).


init() ->
    eunit_http:init().

performGet_test_() ->
    Res = ?performGet("https://github.com/about"),
    [?_assertStatus(Res, 200),
     ?_assertError({assertStatus_failed, _}, ?assertStatus(Res, 400)),

     ?_assertBodyContains(Res, "GitHub"),
     ?_assertError({assertContains_failed, _},
        ?assertBodyContains(Res, "HubGit")),

     ?_assertHeader(Res, "Date"),
     ?_assertError({assertHeader_failed, _},
        ?assertHeader(Res, "X-Missing")),

     ?_assertHeaderVal(Res, "Content-Type", "text/html; charset=utf-8"),
     ?_assertError({assertHeaderVal_failed, _},
        ?assertHeaderVal(Res, "Content-Type", "application/json"))].
