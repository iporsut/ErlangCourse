-module(chat).

-export([start/0, accept_client/2, server/1, client/2]).

-define(PORT, 20715).

server(Clients) ->
    receive
        {connect, Client} ->
            NewClients = [Client|Clients],
            Client ! {connected, self()},
            server(NewClients);

        {message, Message} ->
            lists:foreach(
              fun(Client) ->
                      Client ! {notify, Message}
              end,
              Clients
             ),
            server(Clients)
    end.

start() ->
    Server = spawn(?MODULE, server, [[]]),
    {ok, Listen} = gen_tcp:listen(?PORT, [
            binary,
            {reuseaddr, true},
            {active, true}
        ]),

    spawn(?MODULE, accept_client, [Listen, Server]).

accept_client(Listen, Server) ->

    {ok, Socket} = gen_tcp:accept(Listen),
    
    spawn(?MODULE, accept_client, [Listen, Server]),
    Server ! {connect, self()},
    client(Socket,Server).

client(Socket,Server) ->
    receive
        {tcp, Socket, Message} ->
            Server ! {message, Message},
            client(Socket, Server);
        {tcp_closed, Socket} ->
            gen_tcp:close(Socket);

        {notify, Message} ->
            gen_tcp:send(Socket, Message),
            client(Socket, Server)
    end.
