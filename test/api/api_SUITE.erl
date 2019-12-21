%% @doc start application and test it

-module(api_SUITE).
-author("aaron lelevier").
-compile(export_all).
-compile(nowarn_export_all).

init_per_suite(Config0) ->
  {ok, _} = application:ensure_all_started(api),
  Config = [{base_url, "http://localhost:8080"} | Config0],
  Config.

end_per_suite(_Config) ->
  ok = application:stop(api).

all() ->
  ct_helper:all(?MODULE).

%% tests --------------------------------------------------------------------

can_get_index_endpoint(Config) ->
  Url = build_url(Config, "/"),
  {ok, _Response} = httpc:request(Url),
  ok.

can_get_user_list_endpoint(Config) ->
  Url = build_url(Config, "/user"),
  {ok, Response} = httpc:request(Url),
  Bin = api_util:response_to_binary(Response),
  L = jsx:decode(Bin),
  true = is_list(L),
  true = length(L) > 0.

%% helpers --------------------------------------------------------------------

%% builds a complete URL
-spec build_url(Config :: list(), Segment :: string()) -> string().
build_url(Config, Segment) ->
  BaseUrl = proplists:get_value(base_url, Config),
  BaseUrl ++ Segment.
