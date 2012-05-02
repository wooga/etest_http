%% @author Johannes Huning <johannes.huning@wooga.com>
%% @doc OTP application callback module.
-module (eunit_http_app).

% OPT application callbacks.
-behaviour (application).
-export ([start/2, stop/1]).


%% @doc Called upon starting eunit_http;
%%      Starts eunit_http's main supervisor.
start(_StartType, _StartArgs) ->
    eunit_http_sup:start_link().


% @doc Callback; Returns just `ok`.
stop(_State) -> ok.
