%%%-------------------------------------------------------------------
%%% @author aaron lelevier
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(trip_server).

-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-record(trip_server_state, {}).

%%%===================================================================
%%% Spawning and gen_server implementation
%%%===================================================================

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
  {ok, #trip_server_state{}}.

handle_call(_Request, _From, State = #trip_server_state{}) ->
  {reply, ok, State}.

handle_cast(_Request, State = #trip_server_state{}) ->
  {noreply, State}.

handle_info(_Info, State = #trip_server_state{}) ->
  {noreply, State}.

terminate(_Reason, _State = #trip_server_state{}) ->
  ok.

code_change(_OldVsn, State = #trip_server_state{}, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
