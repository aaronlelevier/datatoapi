%%%-------------------------------------------------------------------
%%% @author aaron lelevier
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. Dec 2019 6:39 AM
%%%-------------------------------------------------------------------
-module(api_util).
-author("aaron lelevier").
-include_lib("core/src/macros.hrl").
-export([extract_url_segment/2, response_to_binary/1]).

%% @doc extracts a URL segment by name and returns it as an atom
-spec extract_url_segment(Req::map(), Segment::atom()) -> atom().
extract_url_segment(Req, Name) ->
  Bin = cowboy_req:binding(Name, Req),
  Action = binary_to_atom(Bin, utf8),
  ?DEBUG(Action),
  Action.

response_to_binary(Response) ->
  {Status, _Headers, Content} = Response,
  {_HttpProtocol, 200, "OK"} = Status,
  % Content will be a integer list so convert to binary
  list_to_binary(Content).
