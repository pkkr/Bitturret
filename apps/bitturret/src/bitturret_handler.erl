-module(bitturret_handler).
-behavior(gen_server).

% Managment API
-export([start/0, start_link/0, stop/0]).

% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
         code_change/3]).

% Public API
-export([]).

-record(state, { socket }).

%% ===================================================================
%% Management API
%% ===================================================================

start() ->
    gen_server:start( {local, ?MODULE}, ?MODULE, [], []).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

stop() -> gen_server:cast(?MODULE, stop).

%% ===================================================================
%% gen_server callbacks
%% ===================================================================

init([]) ->
    {ok, Port} = application:get_env(port),
    {ok, IP}   = application:get_env(ip),

    Options = [
        binary,
        {ip, IP},
        {active, true},
        {read_packets, 16},
        {recbuf, 32 * 1024}
    ],

    {ok, Socket} = gen_udp:open(Port, Options),

    {ok, #state{ socket = Socket }}.

handle_call( _Msg, _From, State ) ->
    { reply, ok, State }.

handle_cast( stop, State ) ->
    { stop, normal, State };

handle_cast( _Msg, State ) ->
    { stop, normal, State }.

code_change(_OldVsn, State, _Extra) ->
    { ok, State }.

handle_info( Msg, State ) ->
    bitturret_dispatcher ! Msg,
    { noreply, State }.

terminate( _Reason, _State ) ->
    whatever.

