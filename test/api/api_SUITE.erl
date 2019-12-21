%% @doc start application and test it

-module(api_SUITE).
-author("aaron lelevier").
-compile(export_all).
-compile(nowarn_export_all).

init_per_suite(Config) ->
  {ok, _} = application:ensure_all_started(api),
  Config.

end_per_suite(_Config) ->
  ok = application:stop(api).

all() -> [can_get_index_endpoint].

can_get_index_endpoint(_Config) ->
  Url = "http://localhost:8080/",
  {ok, _Response} = httpc:request(Url),
  ok.
