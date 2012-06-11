# etest_http

etest\_http is a supplementary library for [etest](https://github.com/wooga/etest)
that makes it easy to test http APIs by providing useful assertions and helper
methods.

## Example Test Case

```erlang

-module (my_api_test).
-compile (export_all).

% etest macros
-include_lib ("etest/include/etest.hrl").
% etest_http macros
-include_lib ("etest_http/include/etest_http.hrl").

test_hello_world() ->
    Response = ?perform_get("http://localhost:3000/hello/world"),
    ?assert_status(200, Response),
    ?assert_body_contains("Hello", Response),
    ?assert_body("Hello World", Response).
```

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

There are two kinds of macros which etest_http provides:

The [request macros](https://github.com/wooga/etest_http#request-macros) provide
a simple API to perform HTTP request. They return a response record on which
subsequent assertions are performed.

The [assertion macros](https://github.com/wooga/etest_http#assertion-macros)
provide useful http API related assertions.

### Request Macros

#### perform_get

Perform a `GET` request, returns a response record.

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

Perform a `POST` request, returns a response record.

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
?assert_body(Body, Res).

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
?assert_header_val("X-Signature", Res).
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
