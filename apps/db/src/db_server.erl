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
-export([
  init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3,
  ping/0, select/1, select_where/1]).

-compile(export_all).

%% Macros
-define(SERVER, ?MODULE).
-define(PG_TABLE, "mtb").

%% Records
-record(db_server_state, {}).

%%%===================================================================
%%% Public
%%%===================================================================

%% @doc synchronous perform SELECT query
-spec select(Table :: atom()) -> [map()].
select(Table) ->
  ?DEBUG({pid, self()}),
  L = gen_server:call(?MODULE, {select, Table}),
  convert_nested_jsonb(L).

%% TODO: not in use - should be used w/ query params
%% @doc synchronous perform SELECT query
-spec select_where({Table :: atom(), Key :: atom(), Value :: atom()}) -> [map()].
select_where({Table, Key, Value}) ->
  ?DEBUG({pid, self()}),
  L = gen_server:call(?MODULE, {select_where, {Table, Key, Value}}),
  convert_nested_jsonb(L).

%% @doc synchronous perform SELECT query and returns single record only
-spec select_get({Table :: atom(), Key :: atom(), Value :: atom()}) -> map().
select_get({Table, Key, Value}) ->
  L = select_where({Table, Key, Value}),
  case length(L) of
    0 ->
      #{};
    1 ->
      [H | _] = L,
      H;
    _ ->
      #{error => <<"multiple records returned">>}
  end.

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
handle_call({select_where, QCommand}, _From, State) ->
  ?DEBUG({pid, self()}),
  {reply, select_where0(QCommand), State};
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
-spec select0({Table :: atom()}) -> [tuple()].
select0(Table) ->
  TableName = trans_table_name(Table),
  Qs = "select * from " ++ atom_to_list(TableName),
  query_to_list(Qs).

%% @doc perform SELECT query
-spec select_where0({Table :: atom(), Key :: atom(), Value :: atom()}) -> [tuple()].
select_where0({Table, Key, Value}) ->
  TableName = trans_table_name(Table),
  Qs = "select *"
  " from " ++ atom_to_list(TableName) ++
    " where " ++ atom_to_list(Key) ++ " = " ++
    "'" ++ atom_to_list(Value) ++ "'",
  ?DEBUG(Qs),
  query_to_list(Qs).

trans_table_name(Name) ->
  TableNameMap = #{user => auth_user},
  #{Name := TableName} = TableNameMap,
  TableName.

%% @doc does a SQL query using a QueryString (Qs) and returns as list
-spec query_to_list(Qs :: string()) -> [tuple()].
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
-spec query(Qs :: string()) -> epgsql_cmd_squery:response().
query(Qs) ->
  {ok, C} = connect(),
  epgsql:squery(C, Qs).

%% @doc converts the QResult (query result) to a list of 2 item tuples,
%% that can then be converted to JSON using `jsx`
-spec to_list(QResult :: tuple()) -> list().
to_list(QResult) ->
  {ok, ColInfo, Rows} = QResult,
  ColNames = [ColName || {column, ColName, _ColType, _, _, _, _} <- ColInfo],
  ?DEBUG(ColNames),
  ColTypes = [ColType || {column, _ColName, ColType, _, _, _, _} <- ColInfo],
  L = [lists:zip3(ColNames, ColTypes, tuple_to_list(R)) || R <- Rows],

  ?DEBUG(L),
  % excludes - HACK so password isn't returned in response
  [[X || X <- Y, element(1, X) =/= <<"password">>] || Y <- L].

%% @doc converts a 2d list to JSON
-spec convert_nested_jsonb(NestedList :: [[map()]]) -> [[binary()]].
convert_nested_jsonb(NestedList) ->
  [convert_jsonb(X) || X <- NestedList].

-spec convert_jsonb(L :: [map()]) -> [binary()].
convert_jsonb(L) ->
  convert_jsonb(L, []).

-spec convert_jsonb(list(), Acc :: list()) -> list().
convert_jsonb([], Acc) -> maps:from_list(lists:reverse(Acc));
convert_jsonb([H | T], Acc) ->
  {ColName, ColType, Value} = H,
  Value2 = case ColType of
             jsonb ->
               maps:from_list(jsx:decode(Value));
             _ ->
               Value
           end,
  convert_jsonb(T, [{ColName, Value2} | Acc]).
