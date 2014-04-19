-module(test).

-export([ hello/0, 
          hello/1, 
          factorial/1, 
          sum/1,
          sum_tail/2,
          count/1,          
          average/1,
          command/1,
          double_list/1,
          map/2,
          foldr/3,
          foldl/3,
          process_loop/0,
          list_process/1]).

list_process(List) ->
    receive
        {push, Val} ->
            NewList = [Val| List],
            list_process(NewList);
        print ->
            io:format("~p~n",[List]),
            list_process(List);
        {Caller, pop} ->
            [Val | NewList] = List,
            Caller ! Val,
            list_process(NewList)
    end.

process_loop() ->
    receive
        Message ->
            io:format("Receive : ~s~n",[Message]),
            process_loop()
    end.

double_list([]) -> [];
double_list([H|T]) -> [ H*2 | double_list(T)].

map(_, []) -> [];
map(F, [H|T]) -> [ F(H) | map(F, T)].

%double_list([1,2,3]) => [2,4,6]

factorial(0) -> 1;
factorial(1) -> 1;
factorial(N) when (N > 1) -> 
    N * factorial(N - 1).

sum_tail([], Acc) -> Acc;

sum_tail([H|T], Acc) ->
    sum_tail(T, (Acc + H)).

sum(L) -> sum_tail(L, 0).

foldr(F,Acc, [Y]) -> F(Y, Acc);
foldr(F,Acc, [H|T]) -> foldr(F, F(H,Acc), T).

foldl(_,_,_) -> none_imp.

count([]) -> 0;
count([_|T]) -> 1 + count(T).

average(L) -> 
    if 
        L =/= [] ->
            sum(L) / count(L);
        true ->
            error
    end.

command(Message) ->
    case Message of
        {average, L} -> average(L);
        {sum, L} -> sum(L)
    end.

hello() ->
    io:format("Hello World Erlang.~n").

hello(joe) ->
    io:format("Hello Joe.~n");

hello(mike) ->
    io:format("Hello Mike.~n").
