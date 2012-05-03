## eunit_http

EUnit Assertions for HTTP requests



## Installation

Install eunit_http by adding it as a [rebar](https://github.com/basho/rebar) dependency:

```erlang
% rebar.config:
{deps, [
    { eunit_http, ".*", {git, "git://github.com/johannesh/eunit_http.git"}},
    % ...
]}.
```

Then run `rebar get-deps` to synchronize your dependencies.



## Usage

First of all make sure you initialize `eunit_http` by a call to `eunit_http:init/0` prior using any of the _request macros_ described further below. For now `eunit_http` wraps the HTTP client `lhttpc`, which requires initialization - this will fortunately change in the near future.

The _request macros_ are:

```erlang
performGet(Url, Args...).
performPost(Url, Args...).
performRequest(Method, Url, Args...).
```

Support for more HTTP verbs may be added in the future.

Next, note that all _assertion macros_ perform their checks on a HTTP response record which contains the most important data from the responses received, thus their general form is always: `?assert*(Response, Args...)`.

To summarize, your test cases could possibly look something like this:
```erlang
-module (my_module_tests).
-compile (export_all).
-include_lib ("eunit/include/eunit.hrl").

something_test_() ->
    eunit_http:init(),
    Response = ?performGet("http://localhost:8080/message/1"),
    [?_assertStatus(Response, 200), ?_assertContains("Hello World")].
```

Or you could use a setup/teardown approach:

```erlang
-module (my_module2_tests).
-compile (export_all).
-include_lib ("eunit/include/eunit.hrl").

my_module2_test_()  ->
    {foreach, fun start/0, fun stop/1, [fun test_first_/1, fun test_second_/1]}.

start() -> eunit_http:init().
stop(_) -> application:stop(eunit_http).

test_first_(_) ->
    Res = ?performGet("http://localhost:8080/profile/bob"),
    [?_assertStatus(Res, 200), ?_assertContains("This is you!")].

test_second_(_) ->
    Res = ?performGet("http://localhost:8080/profile/alice"),
    [?_assertHeader(Res, 301), ?_assertHeaderVal(Res, <<"Location">>, <<"/login">>)].
```

The excellent [Learn You Some Erlang](http://learnyousomeerlang.com/eunit#eunit-whats-a-eunit) has more on this

-

_TODO_

**Performing a GET or POST request**

```erlang
?performGet(Url :: string()).
?performGet(Url :: string(), Headers :: [header()]).
?performGet(Url :: string(), Headers :: [header()], Queries :: [query]).

?performPost(Url :: string()).
?performPost(Url :: string(), Headers :: [header()]).
?performPost(Url :: string(), Headers :: [header()], Body :: binary()).
?performPost(Url :: string(), Headers :: [header()], Body :: binary(), Queries :: [query]).
```

Yields a response record required by the test-assertions.

-
-

_TODO_
assertContains(Haystack, Needle)

_TODO_
assertBodyContains(Res, Needle)

_TODO_
assertBody(Res, Body)

_TODO_
assertHeader(Res, HeaderName)

_TODO_
assertHeaderVal

_TODO_
assertStatus

_TODO_
assertJson

_TODO_
assertJsonKey

_TODO_
assertJsonVal

## Notes

* I plan to replace `lhttpc` with the Erlang HTTP Server, as well as `elli`, which will be replaced with the Erlang HTTP Client to minimize dependencies

* JSON is encoded and decoded to and from orddicts, this will change to work with simple proplists instead, I also have to take a look at mochijson
