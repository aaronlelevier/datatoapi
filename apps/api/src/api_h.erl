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
  Table = api_util:extract_url_segment(Req, table),
  QResult = db_server:select(Table),
  ?DEBUG(QResult),
  Body = jsx:encode(QResult),
  {Body, Req, State}.

