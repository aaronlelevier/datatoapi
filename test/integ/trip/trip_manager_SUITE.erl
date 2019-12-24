%%%-------------------------------------------------------------------
%%% @author aaron lelevier
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. Dec 2019 9:08 AM
%%%-------------------------------------------------------------------
-module(trip_manager_SUITE).
-author("aaron lelevier").
-compile(export_all).
-compile(nowarn_export_all).

-export([]).

all() -> ct_helper:all(?MODULE).

mod_exists(_) ->
  {module, trip_manager} = code:load_file(trip_manager),
  {module, trip} = code:load_file(trip).

can_get_state(_) ->
  {ok, _Pid} = trip_manager:start_link(),
  #{} = trip_manager:get_state().

can_start_trip(_) ->
  {ok, _Pid} = trip_manager:start_link(),
  % trip 0
  {ok, {TripId0, TripPid0}} = trip_manager:init_trip(),
  0 = TripId0,
  true = is_pid(TripPid0),
  % trip 1
  {ok, {TripId1, TripPid1}} = trip_manager:init_trip(),
  1 = TripId1,
  true = is_pid(TripPid1).

