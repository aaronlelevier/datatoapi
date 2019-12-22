%%%-------------------------------------------------------------------
%%% @author aaron lelevier
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Dec 2019 5:50 AM
%%%-------------------------------------------------------------------
-module(trip_report_h).
-author("aaron lelevier").

%% cowboy
-export([
  init/2,
  websocket_init/1,
  websocket_handle/2,
  websocket_info/2]).

init(Req, Opts) ->
  {cowboy_websocket, Req, Opts}.

websocket_init(State) ->
  erlang:start_timer(1000, self(), <<"Hello!">>),
  {ok, State}.

websocket_handle({text, Msg}, State) ->
  {reply, {text, << "That's what she said! ", Msg/binary >>}, State};
websocket_handle(_Data, State) ->
  {ok, State}.

websocket_info({timeout, _Ref, Msg}, State) ->
  erlang:start_timer(1000, self(), <<"How' you doin'?">>),
  {reply, {text, Msg}, State};
websocket_info(_Info, State) ->
  {ok, State}.

