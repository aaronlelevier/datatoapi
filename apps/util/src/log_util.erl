%% @doc example of reading and searching a log file of that's
%% a proplist

-module(log_util).
-author("aaron lelevier").
-export([
  open_log/0, close_log/1, read_log/2, search_for/2]).

%% TODO: hardcoded log contents here should be replaced w/ reading a log file
open_log() ->
  [
    {info, {"foo", not_ok}},
    {restart, {"restart successful", ok}}
  ].

%% TODO: change when open_log/1 changes
close_log(A) -> A.

%% filters a proplist by keys and returns values only
-spec read_log(atom(), list()) -> list().
read_log(restart, L) ->
  [Val || {_, Val} <- proplists:lookup_all(restart, L)];
read_log(all, L) ->
  [Val || {_, Val} <- L].

-spec search_for(Key :: any(), [{Key :: any(), Value :: any()}]) ->
  {match, Line :: integer()} | nomatch.
search_for(Key, L) ->
  search_for(Key, L, 0).

search_for(_Key, [], _Idx) -> nomatch;
search_for(Key, [{Key, _Val} | _], Idx) -> {match, Idx};
search_for(Key, [_ | T], Idx) -> search_for(Key, T, Idx + 1).
