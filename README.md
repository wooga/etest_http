## etest_http

ETest Assertions for HTTP responses



## Installation

Install etest\_http by adding it as a [rebar](https://github.com/basho/rebar)
dependency:

```erlang
% rebar.config:
{deps, [
    {etest_http, "", {git, "git://github.com/wooga/etest_http.git"}},
    % ...
]}.
```

Then run `rebar get-deps` to synchronize your dependencies.



## Usage

The _request macros_ are:

```erlang
?perform_get(Url, Args...).
?perform_post(Url, Args...).
?perform_request(Method, Url, Args...).
```

Next, note that all _assertion macros_ perform their checks on a HTTP response
record which contains the most important data from the responses received, thus
their general form is always: `?assert*(Response, Args...)`.

Your test cases could possibly look something like this:
```erlang
% my_module_test.erl
-module (my_module_test).
-compile (export_all).
-include_lib ("etest/include/etest.hrl").
-include_lib ("etest_http/include/etest_http.hrl").

something_test() ->
    Response = ?perform_get("http://localhost:8080/message/1"),
    ?assert_status(Response, 200),
    ?assert_contains("Hello World").
```



### Request Macros

Assertion macros operate on a _response record_, obtainable via the request
macros.

#### perform_get

Perform a `GET` request, yielding a response record.

```erlang
Res = ?perform_get(Url).
Res = ?perform_get(Url, Headers).
Res = ?perform_get(Url, Headers, Queries).

% Url = string()
% header() :: {string() | binary() | atom(), string() | binary()}
% Headers = [header()]
% query() :: [{string(), string()}]
% Queries = [query()]
```

****

#### perform_post

Perform a `POST` request, yielding a response record.

```erlang
Res = ?perform_post(Url).
Res = ?perform_post(Url, Headers).
Res = ?perform_post(Url, Headers, Body).
Res = ?perform_post(Url, Headers, Body, Queries).

% Url = string()
% header() :: {string() | binary() | atom(), string() | binary()}
% Headers = [header()]
% query() :: [{string(), string()}]
% Queries = [query()]
% Body = binary()
```


### Assertion Macros

All assertions macros are available as _test macros_ and _test generator macros_.

#### assert_contains

Assert that the `Haystack` contains the `Needle`, fail with `assert_contains`
otherwise.

```erlang
% Test Macro.
?assert_contains(Needle, Haystack).

% Test Generator Macro.
?assert_contains(Needle, Haystack).

% Needle = string()
% Haystack = string()
```

****

#### assert_body_contains

Assert that the body received with the response `Res` contains the string
`Needle`, fail with `assert_contains` otherwise too.

```erlang
% Test Macro.
?assert_body_contains(Needle, Res).

% Test Generator Macro.
?assert_body_contains(Needle, Res).

% Needle = string()
```

****

#### assert_body

Assert that the body received with the response `Res` is exactly `Body`, fail
with `assert_equal` otherwise.

```erlang
?assert_body(Body, Resr).

% Test Generator Macro.
?assert_body(Body, Res).

% Body = binary()
```

**Planned for future versions:**
* Support for regular expressions

****

#### assert_header

Assert that the presence of a header `HeaderName` in the headers received with
the response `Res`, fail with `assert_header` otherwise.

```erlang
% Test Macro.
?assert_header(HeaderName, Res).

% Test Generator Macro.
?assert_header(HeaderName, Res).

% HeaderName = string()

% Examples:
?assert_header_val("X-Signature").
```

****

#### assert_header_value

Assert that the headers received with the response `Res` has a header
`HeaderName` with value `HeaderValue`, fail with `assert_header_value` otherwise.

```erlang
% Test Macro.
?assert_header_val(HeaderName, HeaderValue, Res).

% Test Generator Macro.
?assert_header_val(HeaderName, HeaderValue, Res).

% HeaderName = string()
% HeaderVal = string()

% Examples:
?assert_header_val(
    "X-Signature", "42UVoTWYp9I-wdWJsQYUyEXRoCI1wCXmOVPqwdV8LU0=", Res).
```

****

#### assert_status

Assert that the response's HTTP status code is `StatusCode`, fail with
`assert_status` otherwise.

```erlang
% Test Macro.
?assert_status(StatusCode, Res).

% Test Generator Macro.
?assert_status(StatusCode, Res).

% StatusCode = integer()

% Example:
?assert_status(200, Res).
```

****

#### assert_json

Assert that the body received with the response `Res` contains a JSON structure
equal to `JsonStruct`, fail with `assert_equal` otherwise.

```erlang
% Test Macro.
?assert_json(JsonStruct, Res).

% Test Generator Macro.
?assert_json(JsonStruct, Res).

% JsonStruct = orddict()

% Example:
?assert_json([{message, "Hello World"}], Res).
```

****

#### assert_json_key

Assert that the body received with the response `Res` contains a JSON object,
which has a key `Key` with arbitrary contents, fail with `assert_json_key`
otherwise.

```erlang
% Test Macro.
?assert_json_key(Key, Res).

% Test Generator Macro.
?assert_json_key(Key, Res).

% Key = binary() | [binary()]

% Examples:
?assert_json_key(<<"message">>, Res).
?assert_json_key([<<"messages">>, <<"en">>], Res).
```

****

#### assert_json_value

Assert that the body received with the response `Res` contains a JSON object, which under the key `Key` contains exactly `Val`, fail with `assert_json_value` otherwise.

```erlang
% Test Macro.
?assert_json_value(Key, Val, Res).

% Test Generator Macro.
?assert_json_value(Key, Val, Res).

% Key = binary() | [binary()]
% Val = atom() | binary() | list() | integer() | float() | {list()}

% Examples:
?assert_json_value(<<"message">>, <<"Hello World">>, Res).
?assert_json_value(<<"should_reload">>, true, Res).
?assert_json_value([<<"messages">>, <<"de">>], <<"Hallo Welt">>, Res).
```
