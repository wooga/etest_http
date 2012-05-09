## eunit_http

EUnit Assertions for HTTP requests



## Installation

Install eunit_http by adding it as a [rebar](https://github.com/basho/rebar) dependency:

```erlang
% rebar.config:
{deps, [
    {eunit_http, ".*", {git, "git://github.com/johannesh/eunit_http.git"}},
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

Your test cases could possibly look something like this:
```erlang
% my_module_tests.erl
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
% my_module2_tests.erl
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

The excellent [Learn You Some Erlang](http://learnyousomeerlang.com/eunit#eunit-whats-a-eunit) has more on EUnit in general.


### Request Macros

_TODO_

Two variants, test macro and generator macro.
Yields a response record required by the test-assertions.

#### performGet

_TODO_

```erlang
?performGet(Url :: string()).
?performGet(Url :: string(), Headers :: [header()]).
?performGet(Url :: string(), Headers :: [header()], Queries :: [query]).
```

****

#### performPost

_TODO_

```erlang
?performPost(Url :: string()).
?performPost(Url :: string(), Headers :: [header()]).
?performPost(Url :: string(), Headers :: [header()], Body :: binary()).
?performPost(Url :: string(), Headers :: [header()], Body :: binary(), Queries :: [query]).
```


### Assertion Macros

_TODO_

#### assertContains

Assert that the string `Haystack` contains the string `Needle`, fails with `assertContains_failed` otherwise.

```erlang
% Test Macro.
?assertContains(Haystack, Needle).

% Test Generator Macro.
?_assertContains(Haystack, Needle).
```

****

#### assertBodyContains

Assert that the body received with the response `Res` contains the string `Needle`, fails with `assertContains_failed` otherwise too.

```erlang
% Test Macro.
?assertBodyContains(Res, Needle).

% Test Generator Macro.
?_assertBodyContains(Res, Needle).
```

****

#### assertBody

Assert that the body received with the response `Res` is exactly `Body`, fails with `assertEqual_failed` otherwise.

```erlang
?assertBody(Res, Body).

% Test Generator Macro.
?_assertBody(Res, Body).
```

**Planned for future versions:**
* Support for regular expressions

****

#### assertHeader

```erlang
% Test Macro.
?assertHeader(Res, HeaderName).

% Test Generator Macro.
?_assertHeader(Res, HeaderName).
```

****

#### assertHeaderVal

_TODO_

```erlang
% Test Macro.
?assertHeaderVal(Res, HeaderName, HeaderVal).

% Test Generator Macro.
?_assertHeaderVal(Res, HeaderName, HeaderVal).
```

****

#### assertStatus

_TODO_

```erlang
% Test Macro.
?assertStatus(Res, StatusCode).

% Test Generator Macro.
?_assertStatus(Res, StatusCode).
```

****

#### assertJson

_TODO_

```erlang
% Test Macro.
?assertJson(Res, JsonStruct).

% Test Generator Macro.
?_assertJson(Res, JsonStruct).
```

****

#### assertJsonKey

Assert that the body received with the response `Res` contains a JSON object, which has a key `Key` with arbitrary contents, fails with `assertJsonKey_failed` otherwise.

```erlang
% Test Macro.
?assertJsonKey(Res, Key).

% Test Generator Macro.
?_assertJsonKey(Res, Key).

% Key :: binary() | [binary()]

% Examples:
?assertJsonKey(Res, <<"message">>).
?assertJsonKey(Res, [<<"messages">>, <<"en">>]).
```

**Planned for future versions:**
* Support for regular expressions

****

#### assertJsonVal

Assert that the body received with the response `Res` contains a JSON object, which under the key `Key` contains exactly `Val`, fails with `assertJsonVal_failed` otherwise.

```erlang
% Test Macro.
?assertJsonVal(Res, Key, Val).

% Test Generator Macro.
?_assertJsonVal(Res, Key, Val).

% Key :: binary() | [binary()]
% Val :: atom() | binary() | list() | integer() | float() | {list()}

% Examples:
?assertJsonVal(Res, <<"message">>, <<"Hello World">>).
?assertJsonVal(Res, <<"should_reload">>, true).
?assertJsonVal(Res, [<<"messages">>, <<"de">>], <<"Hallo Welt">>).
```

**Planned for future versions:**
* Support for regular expressions



## Notes

* I plan to replace `lhttpc` with the Erlang HTTP Server, as well as `elli`, which will be replaced with the Erlang HTTP Client to minimize dependencies

* JSON is encoded and decoded to and from orddicts, this will change to work with simple proplists instead
