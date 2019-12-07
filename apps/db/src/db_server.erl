%%%-------------------------------------------------------------------
%%% @author aaron lelevier
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(db_server).

-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
  code_change/3]).

%% Debugging
-compile(export_all).

%% Macros
-define(SERVER, ?MODULE).
-define(PG_TABLE, "djangoaws").
%% compile cmd: c(db_server, {d, debug_flag}).
-ifdef(ldebug_flag).
-define(DEBUG(X), io:format("DEBUG ~p:~p ~p~n",[?MODULE, ?LINE, X])).
-else.
-define(DEBUG(X), void).
-endif.

%% Records
-record(db_server_state, {}).

%%%===================================================================
%%% Spawning and gen_server implementation
%%%===================================================================

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
  {ok, #db_server_state{}}.

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

-spec select({Service::atom(), Action::atom}) -> [tuple()].
select({Service, Action}) ->
  % ex: {select, instance}
  {CrudMethod, ResourceType} = crud_method_and_resource_type(Action),
  Qs = CrudMethod ++ " * from " ++ atom_to_list(Service) ++ "_" ++ ResourceType,
  ?DEBUG(Qs),
  query_to_list(Qs).

%% @doc does a SQL query using a QueryString (Qs) and returns as list
-spec query_to_list(Qs::string()) -> [tuple()].
query_to_list(Qs) ->
  to_list(query(Qs)).

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
convert_jsonb([], Acc) -> lists:reverse(Acc);
convert_jsonb([H|T], Acc) ->
  {ColName, ColType, Value} = H,
  Value2 = case ColType of
             jsonb ->
               jsx:decode(Value);
             _ ->
               Value
           end,
  convert_jsonb(T, [{ColName, Value2}|Acc]).

-spec crud_method_and_resource_type(Action::atom()) -> {
  CrudMethod::string(), % ex: "select"
  ResourceType::string() % ex: "ec2"
}.
crud_method_and_resource_type(Action) ->
  {Method, ResourceType0} = split_action(Action),
  ?DEBUG({Method, ResourceType0}),

  ResourceType = core_util:singularize(ResourceType0),

  Key = list_to_atom(Method),
  #{Key := CrudMethod} = #{describe => "select"},
  {CrudMethod, ResourceType}.

%% @doc ex: splits the Action `describe_instances` into `{"describe", "instance"
-spec split_action(Action::atom()) -> {Method::string(), ResourceType::string()}.
split_action(Action) ->
  S = atom_to_list(Action),
  L = string:split(S, "_"),
  list_to_tuple(L).
