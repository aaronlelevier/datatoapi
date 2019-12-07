%%%-------------------------------------------------------------------
%%% @author aaron lelevier
%%% @copyright (C) 2019, <COMPANY>
%%% @doc API endpoint for Service: EC2, Action: describe_instances
%%%
%%% @end
%%% Created : 07. Dec 2019 1:42 PM
%%%-------------------------------------------------------------------
-module(api_ec2_h).
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
  Action = decode_action(Req),
  QResult = db_server:select({ec2, Action}),
  ?DEBUG(QResult),
  Body = jsx:encode(QResult),
  {Body, Req, State}.

decode_action(Req) ->
  Bin0 = cowboy_req:binding(action, Req),
  Str = binary_to_list(Bin0),
  Action = list_to_atom(string:join(string:replace(Str, "-", "_"), "")),
  ?DEBUG(Action),
  Action.
