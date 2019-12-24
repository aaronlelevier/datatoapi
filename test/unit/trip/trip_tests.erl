-module(trip_tests).
-include_lib("eunit/include/eunit.hrl").

name_test() ->
  ?assertEqual(trip0, trip:name(0)).

