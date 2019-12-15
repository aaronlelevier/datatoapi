%%%-------------------------------------------------------------------
%%% @author aaron lelevier
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. Dec 2019 6:37 AM
%%%-------------------------------------------------------------------
-module(user_get_h).
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
  UserId = api_util:extract_url_segment(Req, user_id),
  QResult = db_server:select_get({user, id, UserId}),
  ?DEBUG(QResult),
  Body = jsx:encode(QResult),
  {Body, Req, State}.
