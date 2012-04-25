%% @license GNU General Public License (GPL) Version 3
%% @doc Application initialization module.
-module (eunit_http).
-export ([start/0]).

%% @doc Starts eunit_http, including all dependencies.
start() ->
    Deps = [crypto, public_key, ssl, lhttpc, eunit_http],
    [application:start(Dep) || Dep <- Deps].
