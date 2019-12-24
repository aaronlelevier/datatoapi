%%%-------------------------------------------------------------------
%%% @author aaron lelevier
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(trip_manager).

-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

%% TODO: remove when done
-compile(export_all).

%%%===================================================================
%%% Spawning and gen_server implementation
%%%===================================================================

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%% @doc trip_manager's are initialized with State of an empty Map
%% the Map is used to track Trips that the trip_manager is managing
%% where the Key is an TripId, and the Value is the TripPid
init([]) ->
  {ok, #{}}.

handle_call(init_trip, _From, State0) ->
  TripId = maps:size(State0),
  {ok, TripPid} = trip:start_link(TripId),
  Reply = {ok, {TripId, TripPid}},
  State = State0#{TripId => TripPid},
  {reply, Reply, State};
handle_call(get_state, _From, State) ->
  {reply, State, State};
handle_call(_Request, _From, State) ->
  {reply, ok, State}.

handle_cast(_Request, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Public functions
%%%===================================================================
get_state() -> gen_server:call(?MODULE, get_state).

init_trip() -> gen_server:call(?MODULE, init_trip).

%%%===================================================================
%%% Internal functions
%%%===================================================================
