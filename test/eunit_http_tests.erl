-module (eunit_http_tests).
-include_lib ("eunit/include/eunit.hrl").

-include_lib ("eunit_http/include/eunit_http.hrl").
-export ([init/0]).
-on_load (init/0).


init() ->
    eunit_http:init().

performGet_test_() ->
    Res = ?performGet("http://quobor.com"),
    [
        ?_assertStatus(Res, 200)
    ].

