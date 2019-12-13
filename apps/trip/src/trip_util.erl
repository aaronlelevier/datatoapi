%%%-------------------------------------------------------------------
%%% @author aaron lelevier
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. Dec 2019 6:57 AM
%%%-------------------------------------------------------------------
-module(trip_util).
-author("aaron lelevier").
-export([now_datetime/0]).

now_datetime() ->
  Now = erlang:timestamp(),
  calendar:now_to_local_time(Now).
