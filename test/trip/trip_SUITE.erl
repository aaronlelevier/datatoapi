%% @doc learning `common test`
%% docs: https://erlang.org/doc/apps/common_test/getting_started_chapter.html
%%
%% run all common test's cmd:
%% $ rebar3 ct
%%
%% show common test CL args cmd:
%% $ rebar3 help ct
%% @end

-module(trip_SUITE).
-compile(export_all).
-compile(nowarn_export_all).

all() ->
  [mod_exists].

mod_exists(_) ->
  {module, trip} = code:load_file(trip).
