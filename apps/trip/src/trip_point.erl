%%%-------------------------------------------------------------------
%%% @author aaron lelevier
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. Dec 2019 6:17 AM
%%%-------------------------------------------------------------------
-module(trip_point).
-author("aaron lelevier").
-export([create/1]).
-include("trip.hrl").

%% public API

-spec create({
  Id::integer(), TripId::integer(), Long::float(), Lat::float()}) -> trip.
create({Id, TripId, Long, Lat}) ->
  Dt = trip_util:now_datetime(),
  #trip_point{
    id = Id,
    trip_id = TripId,
    dt = Dt,
    long = Long,
    lat = Lat
  }.