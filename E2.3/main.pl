:- use_module(library(lists)).

:- initialization(load_bc).

load_bc :- 
    exists_file('bc.pl'),
    consult('bc.pl'),
load_bc :-
    writeln('Error al cargar la base de conocimiento. Crear al guardar').

guardar_bc :- 
    open('bc.pl', write, Stream),
    write(Stream, ':- dynamic recomendacion/2.\n\n'),
    forall(recomendacion(Categoria, Lista),
        ( format(Stream, 'recomendacion(~q,~q).\n', [Categoria, Lista]))),
    close(Stream),
    write('Base de conocimiento guardada con exito'),
    nl.

buscar_elem(Categoria, Elemento) :-
    recomendacion(Categoria, Lista),
    (member (Elemento, Lista) 
    -> format('Elemento encontrado: ~q\n', [Elemento, Categoria])
    ; format('Elemento no encontrado, ¿Deseas agregarlo? (s/n)\n', [Elemento, Categoria]),
    read(Resp),
    (Resp == s -> agregar_elem(Categoria, Elemento) ; writeln('Operación cancelada'))).

listar_elem([]).
listar_elem([H|T]) :- 
    format('- ~w~n', [H]),
    listar_elem(T).

comprobar_lista(Categoria) :- 
    recomendacion(Categoria, Lista),
    format('~nRecomendaciones para ~w:~n', [Categoria]),
    listar_elem(Lista).)