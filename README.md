## eunit_http

EUnit Assertions for HTTP requests



## Installation

Install eunit_http by adding it as a [rebar](https://github.com/basho/rebar)
dependency:

```erlang
% In your rebar.config:
{deps, [
    % ...
    { eunit_http, ".*", {git, "git://github.com/johannesh/eunit_http.git"}}
    % ...
]}.
```

Then run `rebar get-deps` to sync your dependencies.



## Usage

Following you see the list of assertions introduced by `eunit_http` and their
usage. Additionally you may consult `eunit_http_tests.erl` where the
assertions itself are being put to the test.


### Initializing

`eunit_http` requires initialization since it, for now, encapsulates a http
client, namely `lhttpc`. Thus you're required to call `eunit_http:init/0`
**once** before your test cases.



## Notes

* I plan to replace `lhttpc` with the Erlang HTTP Server, as well as `elli`,
    which will be replaced with the Erlang HTTP Client.
    This happens to minimize dependencies,

* JSON is encoded and decoded to and from orddicts, this will change to work
    with simple proplists instead, I also have to take a look at mochijson,

* Lack of time forced me to implement things in a way that I am currently not
    very happy with, so over the coming weeks I will attempt to correct my
    shortcomings.
