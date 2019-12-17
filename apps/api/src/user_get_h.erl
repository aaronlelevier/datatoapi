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
  QResult = try api_util:extract_url_segment(Req, user_id) of
              UserId ->
                % GET - [:user_id] segment in URL case
                ?DEBUG(UserId),
                db_server:select_get({user, id, UserId})
            catch
              error:badarg ->
                case cowboy_req:parse_qs(Req) of
                  [] ->
                    % LIST - no query params
                    db_server:select(user);
                  [{Key, Value}] ->
                    % LIST - with query params
                    Key2 = binary_to_atom(Key, utf8),
                    Value2 = binary_to_atom(Value, utf8),
                    db_server:select_where({user, Key2, Value2})
                end
            end,

  ?DEBUG(QResult),
  Body = jsx:encode(QResult),
  {Body, Req, State}.
