%%%-------------------------------------------------------------------
%%% @author aaron lelevier
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(trip).
-behaviour(gen_server).
-include("trip.hrl").

%% public API

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
  code_change/3]).
-export([create/1]).

%% private API

-define(SERVER, ?MODULE).

-record(trip_state, {}).

%% TODO: remove when done
-compile(export_all).

%%%===================================================================
%%% Spawning and gen_server implementation
%%%===================================================================

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

-spec start_link(Id::integer()) -> {ok, pid()}.
start_link(Id) ->
  gen_server:start_link({local, name(Id)}, ?MODULE, [], []).

init([]) ->
  {ok, #trip_state{}}.

handle_call(_Request, _From, State = #trip_state{}) ->
  {reply, ok, State}.

handle_cast(_Request, State = #trip_state{}) ->
  {noreply, State}.

handle_info(_Info, State = #trip_state{}) ->
  {noreply, State}.

terminate(_Reason, _State = #trip_state{}) ->
  ok.

code_change(_OldVsn, State = #trip_state{}, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

-spec create({
  Id::integer(), TripId::integer(), Long::float(), Lat::float()}) -> trip.
create({Id, TripId, Long, Lat}) ->
  Dt = trip_util:now_datetime(),
  #trip_point{
    id = Id,
    trip_id = TripId,
    dt = Dt,
    long = Long,
    lat = Lat
  }.

%% use for creating unique names for Trip gen_server processes
-spec name(Id::integer()) -> atom().
name(Id) -> list_to_atom(atom_to_list(?MODULE) ++ integer_to_list(Id)).