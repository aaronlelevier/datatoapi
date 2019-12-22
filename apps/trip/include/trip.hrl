%%%-------------------------------------------------------------------
%%% @author aaron lelevier
%%% @copyright (C) 2019, <COMPANY>
%%% @doc Records to use across "trip" app modules
%%%
%%% LatLong Ref: https://journeynorth.org/tm/LongitudeIntro.html
%%%
%%% @end
%%% Created : 13. Dec 2019 6:34 AM
%%%-------------------------------------------------------------------
-author("aaron lelevier").

%% @doc User that makes Trips
-record(user, {
  id = 0,
  username = ""
}).

%% @doc a single Trip consisting of multiple TripPoint's
-record(trip, {
  id = 0,
  user_id = #user.id,
  trip_points = [],
  name = "",
  start = {0.0, 0.0},
  finish = {0.0, 0.0},
  distance = 0.0
}).

%% @doc a single point along a Trip
-record(trip_point, {
  id = 0,
  trip_id = #trip.id,
  % REVIEW: not sure if this needs to be decoded
  dt = <<"2019-12-22T05:17:01.949746-08:00">>,
  % across - equator is 0
  lat = 0.0,
  % up + down - prime meridian is 0
  long = 0.0
}).