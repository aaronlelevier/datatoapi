%%%-------------------------------------------------------------------
%%% @author aaron lelevier
%%% @copyright (C) 2019, <COMPANY>
%%% @doc Example code for `monitor/2` from Programming Erlang p. 207-8
%%% Docs: http://erlang.org/doc/man/erlang.html#monitor-2
%%% @end
%%% Created : 11. Dec 2019 6:06 AM
%%%-------------------------------------------------------------------
-module(ex_monitor).
-author("aaron lelevier").
-export([on_exit/2, list_to_atom_fun/0, on_exit_fun/1,
  monitor_example_usage/0]).
-include_lib("core/src/macros.hrl").

on_exit(Pid, Fun) ->
  spawn(
    fun() ->
      Ref = monitor(process, Pid),
      receive
        {'DOWN', Ref, process, Pid, Why} ->
          Fun(Why)
      end
    end).

list_to_atom_fun() ->
  fun() ->
    receive X ->
      Val = list_to_atom(X),
      ?DEBUG({list_to_atom, Val}),
      Val
    end
  end.

on_exit_fun(Pid) ->
  fun(Why) ->
    io:format("~p died with:~p ~n", [Pid, Why])
  end.

%% creates a monitored process and then on exit logs the reason for exit
monitor_example_usage() ->
  Pid = spawn(list_to_atom_fun()),
  ?DEBUG({self, self()}),
  ?DEBUG({pid, Pid}),
  % create an "on exit handler"
  _Pid2 = on_exit(Pid, on_exit_fun(Pid)),

  ?DEBUG({pid2, _Pid2}),
  % send message that will trigger "Pid" to die and "Pid2"
  % the "on exit handler" pid should be informed
  Pid ! hello.
