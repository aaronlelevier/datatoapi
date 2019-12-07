%%% @doc Macros used across apps should live here

%% compile cmd: c(db_server, {d, debug_flag}).
-ifdef(debug_flag).
-define(DEBUG(X), io:format("DEBUG ~p:~p ~p~n",[?MODULE, ?LINE, X])).
-else.
-define(DEBUG(X), void).
-endif.