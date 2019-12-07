%%%-------------------------------------------------------------------
%%% @author aaron lelevier
%%% @copyright (C) 2019, <COMPANY>
%%% @doc API endpoint for Service and Action, which are URL segments
%%%
%%% @end
%%% Created : 07. Dec 2019 1:42 PM
%%%-------------------------------------------------------------------
-module(api_h).
-author("aaron lelevier").
-include_lib("core/src/macros.hrl").

%% cowboy
-export([init/2, content_types_provided/2]).

%% app
-export([json_get/2]).

init(Req, Opts) ->
  {cowboy_rest, Req, Opts}.

content_types_provided(Req, State) ->
  {[
    {{<<"application">>, <<"json">>, '*'}, json_get}
  ], Req, State}.

json_get(Req, State) ->
  Service = decode_url_seg(Req, service),
  Action = decode_url_seg(Req, action),
  QResult = db_server:select({Service, Action}),
  ?DEBUG(QResult),
  Body = jsx:encode(QResult),
  {Body, Req, State}.

-spec decode_url_seg(Req::map(), Segment::atom()) -> atom().
decode_url_seg(Req, Segment) ->
  Bin0 = cowboy_req:binding(Segment, Req),
  Str = binary_to_list(Bin0),
  Action = list_to_atom(string:join(string:replace(Str, "-", "_"), "")),
  ?DEBUG(Action),
  Action.
