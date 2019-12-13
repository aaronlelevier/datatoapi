%%%-------------------------------------------------------------------
%%% @author aaron lelevier
%%% @copyright (C) 2019, <COMPANY>
%%% @doc Implementation of JWT
%%%
%%% Reference: https://jwt.io/introduction/
%%% @end
%%% Created : 07. Dec 2019 11:04 AM
%%%-------------------------------------------------------------------
-module(core_auth).
-author("aaron lelevier").
-export([header/0, payload/1, base64_encode/1]).

-spec header() -> map().
header() ->
  #{
    alg => <<"HS256">>,
    typ => <<"JWT">>
  }.

payload(Username) ->
  #{
    iss => <<"AWS">>,
    sub => list_to_binary(Username)
  }.

-spec base64_encode(Map::map()) -> binary().
base64_encode(Map) ->
  base64:encode(jsx:encode(Map)).

