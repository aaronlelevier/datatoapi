%% @doc start application and test it

-module(api_SUITE).
-author("aaron lelevier").
-compile(export_all).
-compile(nowarn_export_all).

%% ct --------------------------------------------------------------------

init_per_suite(Config0) ->
  {ok, _} = application:ensure_all_started(api),
  Config = [{base_url, "http://localhost:8080"} | Config0],
  Config.

end_per_suite(_Config) ->
  ok = application:stop(api).

all() ->
  ct_helper:all(?MODULE).

%% tests --------------------------------------------------------------------

can_fetch_index(Config) ->
  Url = build_url(Config, "/"),
  {ok, _Response} = httpc:request(Url),
  ok.

can_fetch_user_list(Config) ->
  do_fetch_returns_data(Config, "/user").

can_fetch_user_with_id(Config) ->
  do_fetch_returns_data(Config, "/user/1").

can_get_user_with_query_param(Config) ->
  do_fetch_returns_data(Config, "/user/?username=aaron").

%% helpers --------------------------------------------------------------------

%% builds a complete URL
-spec build_url(Config :: list(), Segment :: string()) -> string().
build_url(Config, Segment) ->
  BaseUrl = proplists:get_value(base_url, Config),
  BaseUrl ++ Segment.

do_fetch_returns_data(Config, UrlSegment) ->
  Url = build_url(Config, UrlSegment),
  {ok, Response} = httpc:request(Url),
  Bin = api_util:response_to_binary(Response),
  L = jsx:decode(Bin),
  true = is_list(L),
  true = length(L) > 0.