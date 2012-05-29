-module(gc_agent_sup_test).

-include("common.hrl").
-include_lib("eunit/include/eunit.hrl").

dynamic_agent_test_() -> ?SPAWN_TEST([
      fun () ->
          R = gc_agent_sup:add_sub(#tab_agent{identity = sub}),
          ?assert(is_pid(whereis(gc_monitor))),
          ?assert(is_pid(whereis(gc_agent_sup))),
          ?assert(is_pid(whereis(gc_root_agent))),
          ?assert(is_pid(whereis(gc_sub_agent)))
      end
    ]).

gc_agent_sup_test_() -> ?SPAWN_TEST([
      ?_assert(is_pid(whereis(gc_monitor))),
      ?_assert(is_pid(whereis(gc_agent_sup))),
      ?_assert(is_pid(whereis(gc_root_agent)))
  ]).

setup() ->
  meck:new(gc_db),
  meck:expect(gc_db, get_all, fun(tab_agent) -> [#tab_agent{identity = root}] end),
  meck:expect(gc_db, init_xref, fun(_Type, _Agent) -> ok end),
  meck:expect(gc_db, get_turnover, 
    fun(_Agent) -> [{?DATE, 10}] end),
  meck:expect(gc_db, get_balance, fun(_Agent) -> 1000 end),
  meck:expect(gc_db, monitor, fun (_) -> ok end),
  gc_agent_sup:start_link().

cleanup(_) ->
  meck:unload(gc_db).
