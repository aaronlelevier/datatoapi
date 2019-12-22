%%%-------------------------------------------------------------------
%% @doc api public API
%% @end
%%%-------------------------------------------------------------------

-module(api_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/", toppage_h, []},
            {"/user/[:user_id]", user_h, []},
            {"/table/[:table]", api_h, []},
            {"/trip_point/[:trip_id]", trip_point_h, []},

            % trip reporting via websocket
            {"/trip_reporter/[:trip_id]",
                cowboy_static, {priv_file, api, "index.html"}},
            {"/websocket", trip_report_h, []},
            {"/static/[...]", cowboy_static, {priv_dir, api, "static"}}

            ]}
    ]),
    {ok, _} = cowboy:start_clear(http, [{port, 8080}], #{
        env => #{dispatch => Dispatch}
    }),
    api_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
