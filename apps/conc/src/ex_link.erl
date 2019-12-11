%%%-------------------------------------------------------------------
%%% @author aaron lelevier
%%% @copyright (C) 2019, <COMPANY>
%%% @doc Example of `link` / `spawn_link` usage - links example p.209
%%% Docs: http://erlang.org/doc/man/erlang.html#spawn_link-1
%%% @end
%%% Created : 11. Dec 2019 6:36 AM
%%%-------------------------------------------------------------------
-module(ex_link).
-author("aaron lelevier").
-compile(export_all).
-export([]).
-include_lib("core/src/macros.hrl").

atom_to_list_fun() ->
  fun() ->
    receive X ->
      Val = atom_to_list(X),
      ?DEBUG({atom_to_list_fun, Val}),
      Val
    end
  end.

start_links() ->
  spawn_link(atom_to_list_fun()).

start_no_links() ->
  spawn(atom_to_list_fun()).

%% example of triggering a linked process to die and the caller
%% is also killed because of the `link`
link_example_usage() ->
  Pid1 = start_links(),
  % the process converts list_to_atom so this will cause it to fail
  Pid1 ! 10.

%% example of triggering a process to die and the caller lives b/c not linked
link_example_usage_2() ->
  Pid1 = start_no_links(),
  % the process converts list_to_atom so this will cause it to fail
  Pid1 ! 10.