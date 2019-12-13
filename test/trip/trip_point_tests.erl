-module(trip_point_tests).
-include_lib("eunit/include/eunit.hrl").

create_test() ->
  {Id, TripId, Long, Lat} = {1, 2, 3.0, 4.0},

  Tp = trip_point:create({Id, TripId, Long, Lat}),

  {trip_point, Id, TripId, Dt, Long, Lat} = Tp,
  true = is_tuple(Dt).
