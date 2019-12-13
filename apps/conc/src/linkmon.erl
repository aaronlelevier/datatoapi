%%%-------------------------------------------------------------------
%%% @author aaron lelevier
%%% @copyright (C) 2019, <COMPANY>
%%% @doc WIP - couldn't get working yet
%%% Ref: https://learnyousomeerlang.com/errors-and-processes#links
%%% @end
%%% Created : 11. Dec 2019 5:11 AM
%%%-------------------------------------------------------------------
-module(linkmon).
-author("aaron lelevier").
-export([myproc/0, myproc_a/0, loop/1, chain/1]).
-include_lib("core/src/macros.hrl").

-define(TIMEOUT, 1000).

myproc() ->
  timer:sleep(?TIMEOUT),
  exit(reason).

myproc_a() ->
  Pid = spawn(?MODULE, myproc, []),
  link(Pid),
  loop(Pid).

loop(Pid) ->
  receive
    Msg ->
      ?DEBUG({msg, Msg}),
      Msg
  end,
  loop(Pid).

chain(0) ->
  receive
    _ -> ok
  after 2000 ->
    ?DEBUG({pid, self()}),
    exit("chain dies here")
  end;
chain(N) ->
  Pid = spawn(fun() -> chain(N - 1) end),
  ?DEBUG({spawned, chain, N, Pid}),
  link(Pid),
  loop(Pid).
