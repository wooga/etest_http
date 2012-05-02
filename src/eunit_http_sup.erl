%% @author Johannes Huning <johannes.huning@wooga.com>
%% @doc OTP supervisor module for eunit_http.
-module (eunit_http_sup).

% OPT supervisor callbacks.
-behaviour (supervisor).
-export ([start_link/0, init/1]).


%% @doc Creates a eunit_http supervisor process as part of a supervision tree.
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).


%% @doc Callback; Builds eunit_http's main supervisor spec.
init([]) -> ignore.
