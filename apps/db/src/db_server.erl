%%%-------------------------------------------------------------------
%%% @author aaron lelevier
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(db_server).

-behaviour(gen_server).

-include_lib("core/src/macros.hrl").

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
  code_change/3, select/1, ping/0]).

%% Macros
-define(SERVER, ?MODULE).
-define(PG_TABLE, "djangoaws").

%% Records
-record(db_server_state, {}).

%%%===================================================================
%%% Public
%%%===================================================================

%% @doc synchronous perform SELECT query
-spec select(Thing::{AwsService::string(), Action::string()}) -> [map()].
select(Table) ->
  ?DEBUG({pid, self()}),
  gen_server:call(?MODULE, {select, Table}).

%% @doc services as end-to-end test from gen_server to DB
-spec ping() -> [tuple()].
ping() ->
  select({ec2, describe_instances}).

%%%===================================================================
%%% Spawning and gen_server implementation
%%%===================================================================

start_link() ->
  ?DEBUG(start_link),
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
  {ok, #db_server_state{}}.

handle_call({select, QCommand}, _From, State) ->
  ?DEBUG({pid, self()}),
  {reply, select0(QCommand), State};
handle_call(_Request, _From, State = #db_server_state{}) ->
  {reply, ok, State}.

handle_cast(_Request, State = #db_server_state{}) ->
  {noreply, State}.

handle_info(_Info, State = #db_server_state{}) ->
  {noreply, State}.

terminate(_Reason, _State = #db_server_state{}) ->
  ok.

code_change(_OldVsn, State = #db_server_state{}, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

%% @doc perform SELECT query
-spec select0({Service::atom(), Action::atom}) -> [tuple()].
select0(Table) ->
  Qs = "select * from " ++ atom_to_list(Table),
  query_to_list(Qs).

%% @doc does a SQL query using a QueryString (Qs) and returns as list
-spec query_to_list(Qs::string()) -> [tuple()].
query_to_list(Qs) ->
  to_list(query(Qs)).

%% @doc connect to DB
-spec connect() -> pid().
connect() ->
  epgsql:connect("localhost", "postgres", "postgres", #{
    database => ?PG_TABLE,
    timeout => 4000
  }).

%% @doc performs a query using a SQL string
-spec query(Qs::string()) -> epgsql_cmd_squery:response().
query(Qs) ->
  {ok, C} = connect(),
  epgsql:squery(C, Qs).

%% @doc converts the QResult (query result) to a list of 2 item tuples,
%% that can then be converted to JSON using `jsx`
-spec to_list(QResult:: tuple()) -> list().
to_list(QResult) ->
  {ok, ColInfo, Rows} = QResult,
  ColNames = [ColName || {column, ColName, _ColType, _, _, _, _} <- ColInfo],
  ColTypes = [ColType || {column, _ColName, ColType, _, _, _, _} <- ColInfo],
  L = [lists:zip3(ColNames, ColTypes, tuple_to_list(R)) || R <- Rows],
  [convert_jsonb(X) || X <- L].

-spec convert_jsonb(L::list()) -> list().
convert_jsonb(L) ->
  convert_jsonb(L, []).

-spec convert_jsonb(list(), Acc::list()) -> list().
convert_jsonb([], Acc) -> maps:from_list(lists:reverse(Acc));
convert_jsonb([H|T], Acc) ->
  {ColName, ColType, Value} = H,
  Value2 = case ColType of
             jsonb ->
               maps:from_list(jsx:decode(Value));
             _ ->
               Value
           end,
  convert_jsonb(T, [{ColName, Value2}|Acc]).
