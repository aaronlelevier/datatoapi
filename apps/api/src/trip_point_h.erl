%%%-------------------------------------------------------------------
%%% @author aaron lelevier
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Dec 2019 4:46 AM
%%%-------------------------------------------------------------------
-module(trip_point_h).
-author("aaron lelevier").
-include_lib("core/src/macros.hrl").

%% cowboy
-export([
  init/2, allowed_methods/2, content_types_provided/2,
  content_types_accepted/2]).

%% app
-export([json_get/2, json_post/2]).

init(Req, Opts) ->
  {cowboy_rest, Req, Opts}.

allowed_methods(Req, State) ->
  {[<<"GET">>, <<"POST">>], Req, State}.

content_types_provided(Req, State) ->
  {[
    {{<<"application">>, <<"json">>, '*'}, json_get}
  ], Req, State}.

content_types_accepted(Req, State) ->
  {[
    {{<<"application">>, <<"json">>, '*'}, json_post}
  ], Req, State}.

json_get(Req, State) ->
  Body = jsx:encode(#{foo => bar}),
  {Body, Req, State}.

json_post(Req, State) ->
  % example of reading request body
  {ok, [{Payload, true}], _Req} = cowboy_req:read_urlencoded_body(Req),
  ?DEBUG({payload, Payload}),

  JsonPayload = jsx:decode(Payload),
  ?DEBUG({json_payload, JsonPayload}),

  % example of adding a response payload
  Req2 = Req#{resp_body => jsx:encode(#{hey => <<"you">>})},

  {true, Req2, State}.
