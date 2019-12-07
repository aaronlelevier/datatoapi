%%%-------------------------------------------------------------------
%% @doc datatoapi public API
%% @end
%%%-------------------------------------------------------------------

-module(datatoapi_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    datatoapi_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
