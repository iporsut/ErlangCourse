-module(broadcast).

-export([server/1, client/1]).



client(Server) ->
    receive
        {connected, ServerPID} ->
            client(ServerPID);
        
        {notify, Message} ->
            io:format("Receive Message : ~s~n", [Message]),
            client(Server);

        {broadcast, Message} ->
            Server ! {message, Message},
            client(Server)
    end.

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
        
