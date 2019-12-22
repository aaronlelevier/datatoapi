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
-include_lib("core/src/macros.hrl").

%% cowboy
-export([
  init/2,
  websocket_init/1,
  websocket_handle/2,
  websocket_info/2]).

%% app
-export([loop/0, query/0]).

init(Req, Opts) ->
  io:format("init~n"),
  case whereis(trip_listener) of
    undefined ->
      register(trip_listener, spawn(?MODULE, loop, []));
    Pid ->
      ?DEBUG(Pid)
  end,

  % send an initial msg for testing
  trip_listener ! {self(), {store_x, 9}},

  {cowboy_websocket, Req, Opts, #{
    % default timeout is 60, or 1 min, so make it 2 min instead
    idle_timeout => 120 * 1000
  }}.

websocket_init(State) ->
  erlang:start_timer(1000, self(), <<"Hello!">>),
  {ok, State}.

websocket_handle({text, Msg}, State) ->
  ?DEBUG({self(), Msg, process_info(self(), registered_name)}),
  Msg2 = query_to_msg(),
  ?DEBUG(Msg2),
  {reply, {text, Msg2}, State};
%%  {reply, {text, <<"That's what she said! ", Msg/binary>>}, State};
websocket_handle(_Data, State) ->
  {ok, State}.

query_to_msg() ->
  query_to_msg(query()).

query_to_msg(Query) ->
  case Query of
    X when is_atom(X) -> atom_to_binary(X, utf8);
    X when is_integer(X) -> integer_to_binary(X);
    X -> term_to_binary(X)
  end.

websocket_info({timeout, _Ref, Msg}, State) ->
  erlang:start_timer(1000, self(), query_to_msg()),
  {reply, {text, Msg}, State};
websocket_info(_Info, State) ->
  {ok, State}.

%% query listener for message
query() ->
  Self = self(),
  trip_listener ! {Self, get_x},
  Result = receive
             {found, X} ->
               X;
             Other ->
               Other
           after 1 ->
      no_trips
           end,
  ?DEBUG(Result),
  Result.

loop() ->
  receive
    {Pid, {store_x, N}} ->
      self() ! {x, N},
      Pid ! {stored, N};
    {Pid, get_x} ->
      receive
        {x, N} ->
          Pid ! {found, N}
      after 0 ->
        Pid ! no_x_values_stored
      end
  end,
  loop().
