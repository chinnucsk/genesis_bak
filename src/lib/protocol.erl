-module(protocol).

%%%
%%% OpenPoker protocol
%%%

-export([read/1, write/1]).
-export([id_to_player/1, id_to_game/1]).

-include("common.hrl").
-include("game.hrl").
-include("protocol.hrl").
-include("schema.hrl").

-import(pickle, [pickle/2, unpickle/2, byte/0, 
                 short/0, sshort/0, int/0, sint/0, 
                 long/0, slong/0, list/2, choice/2, 
                 optional/1, wrap/2, tuple/1, record/2, 
                 binary/1, string/0, wstring/0
                ]).

-define(PP_VER, 1).

%%% Skip reading or writing this value

internal() -> 
    {fun(Acc, _) -> Acc end, 
     fun(Bin) -> {undefined, Bin} end}.


timestamp() ->
    tuple({int(), int(), int()}).

usr() ->
    string().
nick() ->
    string().

photo() -> %% photo code, not support custom photo
  string().

pass() ->
    string().

message() ->
    string().

host() ->
    string().

port() ->
    short().

game_type() ->
    byte().

table_name() ->
    string().

rigged_deck() ->
    cards().

seat_count() ->
    int(). % XXX byte()

seats() ->
  byte().

players() ->
  byte().

required_players() ->
    int(). % XXX byte()

joined_players() ->
    int(). % XXX byte()

player_timeout() ->
    int().

start_delay() ->
    int().

amount() ->
  int().

inplay_amount() ->
  amount().

call_amount() ->
    amount().

raise_amount() ->
    amount().

raise_min() ->
    amount().

raise_max() ->
    amount().

stage() ->
    byte().

button() ->
    byte().

sb() ->
    byte().

bb() ->
    byte().

cards() ->
    list(byte(), card()).

card() -> 
    short().

suit() ->
  byte().

face() ->
    byte().

rank() ->
    byte().

player_hand() ->
    record(player_hand, {
             rank(),
             face(),
             face(),
             suit()
            }).

limit() ->
    record(limit, {
             int(),
             int(),
             int(),
             int()
            }).

game_to_id(G) 
  when is_pid(G) ->
    erlang:process_display(self(), backtrace);

game_to_id(GID) 
  when is_integer(GID) ->
    GID.

id_to_game(GID) ->
    global:whereis_name({game, GID}).

game() ->
    game(get(pass_through)).

game(true) ->
    int();

game(_) ->
    wrap({fun game_to_id/1, fun id_to_game/1}, int()).

player_to_id(undefined) ->
    0;
player_to_id(none) ->
    0;
player_to_id(PID) 
  when is_integer(PID) ->
    PID.

id_to_player(0) ->
  undefined;

id_to_player(PID) ->
  global:whereis_name({player, PID}).

player() ->
  player(get(pass_through)).

player(true) ->
  int();

player(_) ->
  wrap({fun player_to_id/1, fun id_to_player/1}, int()).

seat() ->
    byte().

state() ->
    int().

%%% Commands 

bad() ->
    record(bad, {
             byte(),
             byte()
            }).

good() ->
    record(good, {
             byte()
            }).

login() ->
    record(login, {
             usr(),
             pass()
            }).

logout() ->
    record(logout, {
            }).

watch() ->
    record(watch, {
             game(),
             internal()
            }).

unwatch() ->
    record(unwatch, {
             game(),
             internal()
            }).

wait_bb() ->
    record(wait_bb, {
             game(),
             internal()
            }).

raise() ->
    record(raise, {
             game(),
             internal(),
             raise_amount()
            }).

notify_raise() ->
    record(notify_raise, {
             game(),
             player(),
             raise_amount(),
             call_amount()
            }).

notify_blind() ->
    record(notify_blind, {
             game(),
             player(),
             call_amount()
            }).

fold() ->
    record(fold, {
             game(),
             internal()
            }).

join() ->
    record(join, {
             game(),
             seat(),
             amount()
            }).

leave() ->
    record(leave, {
             game(),
             internal(),
             internal()
            }).

notify_join() ->
    record(notify_join, {
             game(),
             player(),
             seat(),
             amount(),
             nick(),
             internal()
            }).

notify_leave() ->
    record(notify_leave, {
             game(),
             player(),
             internal()
            }).

sit_out() ->
    record(sit_out, {
             game(),
             internal()
            }).

come_back() ->
    record(come_back, {
             game(),
             internal()
            }).

chat() ->
    record(chat, {
             game(),
             internal(),
             message()
            }).

notify_chat() ->
    record(notify_chat, {
             game(),
             player(),
             message()
            }).

game_query() ->
    record(game_query, { }).

seat_query() ->
    record(seat_query, {
             game()
            }).

player_query() ->
    record(player_query, {
             player()
            }).

photo_query() ->
    record(photo_query, {
             player()
            }).

balance_query() ->
    record(balance_query, {
            }).

start_game() ->
    record(start_game, {
             table_name(),
             game_type(),
             limit(),
             seat_count(),
             required_players(),
             start_delay(),
             player_timeout(),
             rigged_deck(),
             internal()
            }).

game_info() ->
    record(game_info, {
             game(),
             table_name(),
             limit(),
             seat_count(),
             required_players(),
             joined_players()
            }).

photo_info() ->
  record(photo_info, {
    player(),
    photo()
  }).

player_info() ->
    record(player_info, {
             player(),
             inplay_amount(), 
             nick(),
             photo()
            }).

bet_req() ->
    record(bet_req, {
             game(),
             call_amount(),
             raise_min(),
             raise_max()
            }).

notify_actor() ->
    record(notify_actor, {
             game(), 
             seat()
           }).

notify_draw() ->
    record(notify_draw, {
             game(), 
             player(),
             card()
            }).

notify_private() ->
    record(notify_private, {
             game(), 
             player(),
             card()
            }).

notify_shared() ->
    record(notify_shared, {
             game(),
             card()
            }).

notify_start_game() ->
    record(notify_start_game, {
             game()
            }).

notify_button() ->
    record(notify_button, {
             game(),
             button()
            }).

notify_sb() ->
    record(notify_sb, {
             game(),
             sb()
            }).

notify_bb() ->
    record(notify_bb, {
             game(),
             bb()
            }).

notify_end_game() ->
    record(notify_end_game, {
             int()
            }).

notify_cancel_game() ->
    record(notify_cancel_game, {
             int()
            }).

notify_win() ->
    record(notify_win, {
             game(),
             player(),
             amount(),
             amount()
            }).

notify_hand() ->
    record(notify_hand, {
             game(),
             player(),
             player_hand()
            }).

muck() ->
    record(muck, {
             game(),
             internal()
            }).

game_stage() ->
    record(game_stage, {
             game(),
             stage()
            }).

seat_state() ->
    record(seat_state, {
             game(), 
             seat(),
             state(),
             player(),
             amount(), % inplay
             amount(), % bet
             nick(),
             photo()
            }).

you_are() ->
    record(you_are, {
             player()
            }).

goto() ->
    record(goto, {
             port(),
             host() 
            }).

balance() ->
    record(balance, {
             int(),
             int()
            }).

your_game() ->
    record(your_game, {
             game()
            }).

show_cards() ->
    record(show_cards, {
             game(),
             player(),
             cards()
            }).

notify_unwatch() ->
    record(notify_unwatch, {
             game()
            }).

notify_seat_detail() ->
    record(notify_seat_detail, {
             game(), 
             seat(),
             state(),
             player(),
             amount(),
             nick()
           }).

notify_game_detail() ->
  record(notify_game_detail, {
      game(),
      amount(),
      seats(),
      players(),
      stage(),
      limit()
    }).

ping() ->
    record(ping, {
             timestamp()
            }).

pong() ->
    record(pong, {
             timestamp(),
             timestamp(),
             timestamp()
            }).

%%% Pickle

write(R) when is_record(R, bad) ->
    [?CMD_BAD|pickle(bad(), R)];

write(R) when is_record(R, good) ->
    [?CMD_GOOD|pickle(good(), R)];

write(R) when is_record(R, login) ->
    [?CMD_LOGIN|pickle(login(), R)];

write(R) when is_record(R, logout) ->
    [?CMD_LOGOUT|pickle(logout(), R)];

write(R) when is_record(R, watch) ->
    [?CMD_WATCH|pickle(watch(), R)];

write(R) when is_record(R, unwatch) ->
    [?CMD_UNWATCH|pickle(unwatch(), R)];

write(R) when is_record(R, wait_bb) ->
    [?CMD_WAIT_BB|pickle(wait_bb(), R)];

write(R) when is_record(R, raise) ->
    [?CMD_RAISE|pickle(raise(), R)];

write(R) when is_record(R, notify_raise) ->
    [?CMD_NOTIFY_RAISE|pickle(notify_raise(), R)];

write(R) when is_record(R, notify_blind) ->
    [?CMD_NOTIFY_BLIND|pickle(notify_blind(), R)];

write(R) when is_record(R, notify_unwatch) ->
    [?CMD_NOTIFY_UNWATCH|pickle(notify_unwatch(), R)];

write(R) when is_record(R, fold) ->
    [?CMD_FOLD|pickle(fold(), R)];

write(R) when is_record(R, join) ->
    [?CMD_JOIN|pickle(join(), R)];

write(R) when is_record(R, notify_join) ->
    [?CMD_NOTIFY_JOIN|pickle(notify_join(), R)];

write(R) when is_record(R, leave) ->
    [?CMD_LEAVE|pickle(leave(), R)];

write(R) when is_record(R, notify_leave) ->
    [?CMD_NOTIFY_LEAVE|pickle(notify_leave(), R)];

write(R) when is_record(R, sit_out) ->
    [?CMD_SIT_OUT|pickle(sit_out(), R)];

write(R) when is_record(R, come_back) ->
    [?CMD_COME_BACK|pickle(come_back(), R)];

write(R) when is_record(R, chat) ->
    [?CMD_CHAT|pickle(chat(), R)];

write(R) when is_record(R, notify_chat) ->
    [?CMD_NOTIFY_CHAT|pickle(notify_chat(), R)];

write(R) when is_record(R, game_query) ->
    [?CMD_GAME_QUERY|pickle(game_query(), R)];

write(R) when is_record(R, seat_query) ->
    [?CMD_SEAT_QUERY|pickle(seat_query(), R)];

write(R) when is_record(R, player_query) ->
    [?CMD_PLAYER_QUERY|pickle(player_query(), R)];

write(R) when is_record(R, photo_query) ->
    [?CMD_PHOTO_QUERY|pickle(photo_query(), R)];

write(R) when is_record(R, balance_query) ->
    [?CMD_BALANCE_QUERY|pickle(balance_query(), R)];

write(R) when is_record(R, start_game) ->
    [?CMD_START_GAME|pickle(start_game(), R)];

write(R) when is_record(R, game_info) ->
    [?CMD_GAME_INFO|pickle(game_info(), R)];

write(R) when is_record(R, player_info) ->
    [?CMD_PLAYER_INFO|pickle(player_info(), R)];

write(R) when is_record(R, photo_info) ->
    [?CMD_PHOTO_INFO|pickle(photo_info(), R)];

write(R) when is_record(R, bet_req) ->
    [?CMD_BET_REQ|pickle(bet_req(), R)];

write(R) when is_record(R, notify_draw) ->
    [?CMD_NOTIFY_DRAW|pickle(notify_draw(), R)];

write(R) when is_record(R, notify_actor) ->
    [?CMD_NOTIFY_ACTOR|pickle(notify_actor(), R)];

write(R) when is_record(R, notify_private) ->
    [?CMD_NOTIFY_PRIVATE|pickle(notify_private(), R)];

write(R) when is_record(R, notify_shared) ->
    [?CMD_NOTIFY_SHARED|pickle(notify_shared(), R)];

write(R) when is_record(R, notify_start_game) ->
    [?CMD_NOTIFY_START_GAME|pickle(notify_start_game(), R)];

write(R) when is_record(R, notify_end_game) ->
    [?CMD_NOTIFY_END_GAME|pickle(notify_end_game(), R)];

write(R) when is_record(R, notify_cancel_game) ->
    [?CMD_NOTIFY_CANCEL_GAME|pickle(notify_cancel_game(), R)];

write(R) when is_record(R, notify_win) ->
    [?CMD_NOTIFY_WIN|pickle(notify_win(), R)];

write(R) when is_record(R, notify_hand) ->
    [?CMD_NOTIFY_HAND|pickle(notify_hand(), R)];

write(R) when is_record(R, muck) ->
    [?CMD_MUCK|pickle(muck(), R)];

write(R) when is_record(R, game_stage) ->
    [?CMD_GAME_STAGE|pickle(game_stage(), R)];

write(R) when is_record(R, seat_state) ->
    [?CMD_SEAT_STATE|pickle(seat_state(), R)];

write(R) when is_record(R, you_are) ->
    [?CMD_YOU_ARE|pickle(you_are(), R)];

write(R) when is_record(R, goto) ->
    [?CMD_GOTO|pickle(goto(), R)];

write(R) when is_record(R, balance) ->
    [?CMD_BALANCE|pickle(balance(), R)];

write(R) when is_record(R, notify_button) ->
    [?CMD_NOTIFY_BUTTON|pickle(notify_button(), R)];

write(R) when is_record(R, notify_sb) ->
    [?CMD_NOTIFY_SB|pickle(notify_sb(), R)];

write(R) when is_record(R, notify_bb) ->
    [?CMD_NOTIFY_BB|pickle(notify_bb(), R)];

write(R) when is_record(R, your_game) ->
    [?CMD_YOUR_GAME|pickle(your_game(), R)];

write(R) when is_record(R, show_cards) ->
    [?CMD_SHOW_CARDS|pickle(show_cards(), R)];

write(R) when is_record(R, notify_seat_detail) ->
  [?CMD_NOTIFY_SEAT_DETAIL | pickle(notify_seat_detail(), R)];

write(R) when is_record(R, notify_game_detail) ->
  [?CMD_NOTIFY_GAME_DETAIL | pickle(notify_game_detail(), R)];

write(R) when is_record(R, ping) ->
    [?CMD_PING|pickle(ping(), R)];

write(R) when is_record(R, pong) ->
    [?CMD_PONG|pickle(pong(), R)].

%%% Unpickle

read(<<?CMD_BAD, Bin/binary>>) ->
    unpickle(bad(), Bin);

read(<<?CMD_GOOD, Bin/binary>>) ->
    unpickle(good(), Bin);

read(<<?CMD_LOGIN, Bin/binary>>) ->
  unpickle(login(), Bin);

read(<<?CMD_LOGOUT, Bin/binary>>) ->
    unpickle(logout(), Bin);

read(<<?CMD_WATCH, Bin/binary>>) ->
    unpickle(watch(), Bin);

read(<<?CMD_UNWATCH, Bin/binary>>) ->
    unpickle(unwatch(), Bin);

read(<<?CMD_WAIT_BB, Bin/binary>>) ->
    unpickle(wait_bb(), Bin);

read(<<?CMD_RAISE, Bin/binary>>) ->
    unpickle(raise(), Bin);

read(<<?CMD_NOTIFY_RAISE, Bin/binary>>) ->
    unpickle(notify_raise(), Bin);

read(<<?CMD_NOTIFY_BLIND, Bin/binary>>) ->
    unpickle(notify_blind(), Bin);

read(<<?CMD_NOTIFY_UNWATCH, Bin/binary>>) ->
    unpickle(notify_unwatch(), Bin);

read(<<?CMD_FOLD, Bin/binary>>) ->
    unpickle(fold(), Bin);

read(<<?CMD_JOIN, Bin/binary>>) ->
    unpickle(join(), Bin);

read(<<?CMD_NOTIFY_JOIN, Bin/binary>>) ->
    unpickle(notify_join(), Bin);

read(<<?CMD_LEAVE, Bin/binary>>) ->
    unpickle(leave(), Bin);

read(<<?CMD_NOTIFY_LEAVE, Bin/binary>>) ->
    unpickle(notify_leave(), Bin);

read(<<?CMD_SIT_OUT, Bin/binary>>) ->
    unpickle(sit_out(), Bin);

read(<<?CMD_COME_BACK, Bin/binary>>) ->
    unpickle(come_back(), Bin);

read(<<?CMD_CHAT, Bin/binary>>) ->
    unpickle(chat(), Bin);

read(<<?CMD_NOTIFY_CHAT, Bin/binary>>) ->
    unpickle(notify_chat(), Bin);

read(<<?CMD_GAME_QUERY, Bin/binary>>) ->
    unpickle(game_query(), Bin);

read(<<?CMD_SEAT_QUERY, Bin/binary>>) ->
    unpickle(seat_query(), Bin);

read(<<?CMD_PLAYER_QUERY, Bin/binary>>) ->
  unpickle(player_query(), Bin);

read(<<?CMD_PHOTO_QUERY, Bin/binary>>) ->
  unpickle(photo_query(), Bin);

read(<<?CMD_BALANCE_QUERY, Bin/binary>>) ->
    unpickle(balance_query(), Bin);

read(<<?CMD_START_GAME, Bin/binary>>) ->
    unpickle(start_game(), Bin);

read(<<?CMD_GAME_INFO, Bin/binary>>) ->
    unpickle(game_info(), Bin);

read(<<?CMD_PLAYER_INFO, Bin/binary>>) ->
    unpickle(player_info(), Bin);

read(<<?CMD_PHOTO_INFO, Bin/binary>>) ->
    unpickle(photo_info(), Bin);

read(<<?CMD_BET_REQ, Bin/binary>>) ->
    unpickle(bet_req(), Bin);

read(<<?CMD_NOTIFY_DRAW, Bin/binary>>) ->
    unpickle(notify_draw(), Bin);

read(<<?CMD_NOTIFY_ACTOR, Bin/binary>>) ->
    unpickle(notify_actor(), Bin);

read(<<?CMD_NOTIFY_PRIVATE, Bin/binary>>) ->
    unpickle(notify_private(), Bin);

read(<<?CMD_NOTIFY_SHARED, Bin/binary>>) ->
    unpickle(notify_shared(), Bin);

read(<<?CMD_NOTIFY_START_GAME, Bin/binary>>) ->
    unpickle(notify_start_game(), Bin);

read(<<?CMD_NOTIFY_END_GAME, Bin/binary>>) ->
    unpickle(notify_end_game(), Bin);

read(<<?CMD_NOTIFY_CANCEL_GAME, Bin/binary>>) ->
    unpickle(notify_cancel_game(), Bin);

read(<<?CMD_NOTIFY_WIN, Bin/binary>>) ->
    unpickle(notify_win(), Bin);

read(<<?CMD_NOTIFY_HAND, Bin/binary>>) ->
    unpickle(notify_hand(), Bin);

read(<<?CMD_MUCK, Bin/binary>>) ->
    unpickle(muck(), Bin);

read(<<?CMD_GAME_STAGE, Bin/binary>>) ->
    unpickle(game_stage(), Bin);

read(<<?CMD_SEAT_STATE, Bin/binary>>) ->
    unpickle(seat_state(), Bin);

read(<<?CMD_YOU_ARE, Bin/binary>>) ->
    unpickle(you_are(), Bin);

read(<<?CMD_GOTO, Bin/binary>>) ->
    unpickle(goto(), Bin);

read(<<?CMD_BALANCE, Bin/binary>>) ->
    unpickle(balance(), Bin);

read(<<?CMD_NOTIFY_BUTTON, Bin/binary>>) ->
    unpickle(notify_button(), Bin);

read(<<?CMD_NOTIFY_SB, Bin/binary>>) ->
    unpickle(notify_sb(), Bin);

read(<<?CMD_NOTIFY_BB, Bin/binary>>) ->
    unpickle(notify_bb(), Bin);

read(<<?CMD_YOUR_GAME, Bin/binary>>) ->
    unpickle(your_game(), Bin);

read(<<?CMD_SHOW_CARDS, Bin/binary>>) ->
    unpickle(show_cards(), Bin);

read(<<?CMD_NOTIFY_GAME_DETAIL, Bin/binary>>) ->
  unpickle(notify_game_detail(), Bin);

read(<<?CMD_NOTIFY_SEAT_DETAIL, Bin/binary>>) ->
  unpickle(notify_seat_detail(), Bin);

read(<<?CMD_PING, Bin/binary>>) ->
    unpickle(ping(), Bin);

read(<<?CMD_PONG, Bin/binary>>) ->
    unpickle(pong(), Bin).

%year() ->
    %int().

%month() ->
    %byte().

%day() ->
    %byte().

%date_() ->
    %tuple({year(), month(), day()}).

%hour() ->
    %byte().

%minute() ->
    %byte().

%second() ->
    %byte().

%time_() ->
    %tuple({hour(), minute(), second()}).

%datetime() ->
    %tuple({date_(), time_()}).

-include_lib("eunit/include/eunit.hrl").

id_to_game_test() ->
  PID = spawn(fun loop_fun/0),
  yes = global:register_name({game, 1}, PID),
  ?assertEqual(PID, protocol:id_to_game(1)),
  Data = protocol:write(#watch{game = 1}),
  R = protocol:read(list_to_binary(Data)),
  ?assertEqual(PID, R#watch.game).

seat_query_test() ->
  PID = spawn(fun loop_fun/0),
  yes = global:register_name({game, 10}, PID),
  Data = protocol:write(#seat_query{game = 10}),
  R = protocol:read(list_to_binary(Data)),
  ?assertEqual(PID, R#seat_query.game).


id_to_player_test() ->
  PID = spawn(fun loop_fun/0),
  yes = global:register_name({player, 1}, PID),
  ?assertEqual(PID, protocol:id_to_player(1)),
  Data = protocol:write(#player_query{player = 1}),
  R = protocol:read(list_to_binary(Data)),
  ?assertEqual(PID, R#player_query.player).

notify_game_detail_test() ->
  R = #notify_game_detail{game = 1, pot = 100, players = 4, seats = 5, stage = 0, limit = #limit{max = 10, min = 10, small = 10, big = 20}},
  Data = protocol:write(R),
  R1 = protocol:read(list_to_binary(Data)),
  ?assertEqual(notify_game_detail, element(1, R1)).

seat_state_test() ->
  R = #seat_state{game = 1, seat = 1, state = ?PS_EMPTY, player = 0, inplay = 0, bet = 0, nick = <<"">>, photo = <<"">>},
  R1 = #seat_state{game = 1, seat = 2, state = ?PS_BET, player = 10, inplay = 1000, bet = 10, nick = <<"player">>, photo = <<"default">>},
  Data = protocol:write(R),
  Data1 = protocol:write(R1),
  RR = protocol:read(list_to_binary(Data)),
  RR1 = protocol:read(list_to_binary(Data1)),
  ?assertEqual(?PS_EMPTY, RR#seat_state.state),
  ?assertEqual(?PS_BET, RR1#seat_state.state).

loop_fun() ->
  receive
    _ ->
      loop_fun()
  end.
