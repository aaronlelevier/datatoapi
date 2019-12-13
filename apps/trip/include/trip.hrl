%%%-------------------------------------------------------------------
%%% @author aaron lelevier
%%% @copyright (C) 2019, <COMPANY>
%%% @doc Records to use across "trip" app modules
%%%
%%% @end
%%% Created : 13. Dec 2019 6:34 AM
%%%-------------------------------------------------------------------
-author("aaron lelevier").
-export([]).

%% @doc a single trip consisting of multiple trip points
-record(trip, {
  id = 0,
  trip_points = [],
  name = "",
  start = {0.0, 0.0},
  finish = {0.0, 0.0},
  distance = 0.0
}).

%% @doc a single point along a trip
-record(trip_point, {
  id = 0,
  trip_id = #trip.id,
  dt={{2019, 12, 13}, {6, 42, 0}},
  long=0.0,
  lat=0.0
}).