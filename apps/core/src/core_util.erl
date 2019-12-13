%%%-------------------------------------------------------------------
%%% @author aaron lelevier
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Dec 2019 12:24 PM
%%%-------------------------------------------------------------------
-module(core_util).
-author("aaron lelevier").
-export([singularize/1]).

%% @doc changes a plural to singular - currently by only stripping the "s"
-spec singularize(S::string()) -> string().
singularize(S) ->
  [H|T] = lists:reverse(S),
  case H of
    $s ->
      lists:reverse(T);
    _ ->
      S
  end.