-module(trip_point_tests).
-include_lib("eunit/include/eunit.hrl").

create_test() ->
  {Id, TripId, Lat, Long} = {1, 2, 3.0, 4.0},

  Tp = trip_point:create({Id, TripId, Lat, Long}),

  {trip_point, Id, TripId, Dt, Lat, Long} = Tp,
  ?assertEqual(true, is_tuple(Dt)).
