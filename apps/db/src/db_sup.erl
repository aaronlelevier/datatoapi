%%%-------------------------------------------------------------------
%% @doc db top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(db_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
  {ok, {{one_for_one, 3, 10},
    [{tag1,
      {db_server, start_link, []},
      permanent,
      10000,
      worker,
      [db_server]}
    ]}}.

