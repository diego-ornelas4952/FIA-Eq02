/*
    Diego Josuan Ornelas Durán
    Emmanuel Murillo Picaso
    Jimena Ramirez
    Mario Rizo Romo
    Silvano Joset Valdivia Franco

    E2.3 Construcción de Agentes
    Fecha: 07/03/2026
    Descripción: Agente de Recomendaciones
*/

:- use_module(library(lists)). % Para usar funciones de listas

:- dynamic recomendacion/2.

:- initialization(load_bc). % Carga la base de conocimiento al iniciar

% Predicados para la base de conocimiento
% Carga de la base del conocimiento
load_bc :-
    exists_file('bc.pl'),
    consult('bc.pl').
load_bc :-
    writeln('Error al cargar la base de conocimiento. Crear al guardar').

% Mostrar categorías
show_cats :-
    writeln('\nCategorias disponibles:'),
    forall(recomendacion(Categoria, _), format('- ~w~n', [Categoria])).

% Guardar la base del conocimiento
guardar_bc :-
    open('bc.pl', write, Stream),
    write(Stream, ':- dynamic recomendacion/2.\n\n'),
    forall(recomendacion(Categoria, Lista),
        ( format(Stream, 'recomendacion(~q,~q).\n', [Categoria, Lista]))),
    close(Stream),
    write('Base de conocimiento guardada con exito'),
    nl.

% Predicados para el menu
% Buscar elemento
buscar_elem(Categoria, Elemento) :-
    ( recomendacion(Categoria, Lista)
    -> ( member(Elemento, Lista)
        -> format('Elemento ~q encontrado en la categoria ~q\n', [Elemento, Categoria])
        ;  format('Elemento ~q no encontrado en ~q, ¿Deseas agregarlo? (s/n)\n', [Elemento, Categoria]),
           read(Resp),
           ( Resp == s -> add_elem(Categoria, Elemento) ; true )
       )
    ;  format('La categoría ~q no existe. ¿Deseas crearla y agregar el elemento? (s/n)\n', [Categoria]),
       read(Resp),
       ( Resp == s -> add_elem(Categoria, Elemento) ; writeln('Operacion cancelada') )
    ).

% Listar elementos de una categoría
listar_elem([]).
listar_elem([H|T]) :-
    format('- ~w~n', [H]),
    listar_elem(T).

% Comprobar lista
comprobar_lista(Categoria) :-
    (recomendacion(Categoria, Lista)
    -> format('~nRecomendaciones para ~w:~n', [Categoria]),
       listar_elem(Lista)
    ; format('La categoría ~w no existe~n', [Categoria])).

% Concatenar dos categorías
concat_propia([], L, L).
concat_propia([H|T], L2, [H|L3]) :-
    concat_propia(T, L2, L3).

demo_concat(Cat1, Cat2) :-
    (recomendacion(Cat1, Lista1), recomendacion(Cat2, Lista2)
    -> concat_propia(Lista1, Lista2, LP),
       append(Lista1, Lista2, LAp),
       format('Concatenación propia: ~q~n', [LP]),
       format('Concatenación append: ~q~n', [LAp])
    ; writeln('Una o ambas categorías no existen.')).

% Agregar elemento
add_elem(Categoria, Elemento) :-
    (recomendacion(Categoria, Lista)
    -> retract(recomendacion(Categoria, Lista)),
    append(Lista, [Elemento], NuevaLista)
    ; NuevaLista = [Elemento]),

    assertz(recomendacion(Categoria, NuevaLista)),
    guardar_bc,
    writeln('Elemento agregado con exito').

% Eliminar elemento
del_elem(Categoria, Elemento) :-
    (recomendacion(Categoria, Lista)
    -> (select(Elemento, Lista, NuevaLista)
        -> retract(recomendacion(Categoria, Lista)),
           assertz(recomendacion(Categoria, NuevaLista)),
           guardar_bc,
           writeln('Elemento eliminado con exito')
        ;  writeln('Elemento no encontrado en la lista'))
    ; writeln('Categoría no encontrada')).

% Obtener tamaño de una categoría
size_list([], 0).
size_list([_|T], N) :-
    size_list(T, N1),
    N is N1 + 1.

% Mostrar tamaño de una categoría
show_size(Categoria) :-
    (recomendacion(Categoria, Lista)
    -> size_list(Lista, N),
       format('~nRecomendaciones para ~w: ~q~n', [Categoria, N])
    ; format('La categoría ~w no existe~n', [Categoria])).

% Ordenar lista
ord_lista(Categoria) :-
    (recomendacion(Categoria, Lista)
    -> sort(Lista, ListaSort),
       msort(Lista, ListaMsort),
       format('~nRecomendaciones ordenadas (Sort) para ~w: ~q~n', [Categoria, ListaSort]),
       format('~nRecomendaciones ordenadas (Msort) para ~w: ~q~n', [Categoria, ListaMsort])
    ; format('La categoría ~w no existe~n', [Categoria])).

% Menu
menu :-
    writeln('\n--- Menu ---\n'),
    writeln('1. Mostrar categorías'),
    writeln('2. Buscar elemento'),
    writeln('3. Listar elementos de categoría'),
    writeln('4. Concatenar dos categorías'),
    writeln('5. Agregar elemento'),
    writeln('6. Eliminar elemento'),
    writeln('7. Obtener tamaño de una categoría'),
    writeln('8. Ordenar lista'),
    writeln('9. Salir'),
    write('Seleccione una opcion: '), 
    read(Op),
    exe_op(Op).

exe_op(1) :- 
    show_cats, menu.

exe_op(2) :- 
    write('Ingrese la categoria: '), 
    read(C), write('Ingrese el elemento: '), read(E),
    buscar_elem(C, E), menu.

exe_op(3) :- 
    write('Ingrese la categoria: '), 
    read(C), 
    comprobar_lista(C), menu.

exe_op(4) :- 
    write('Ingrese la categoria 1: '), 
    read(C1), write('Ingrese la categoria 2: '), read(C2),
    demo_concat(C1, C2), menu.

exe_op(5) :- 
    write('Ingrese la categoria: '), 
    read(C), write('Ingrese el elemento que quiere añadir: '), read(E),
    add_elem(C, E), menu.

exe_op(6) :- 
    write('Ingrese la categoria: '), 
    read(C), write('Ingrese el elemento que quiere eliminar: '), read(E),
    del_elem(C, E), menu.

exe_op(7) :- 
    write('Ingrese la categoria: '), 
    read(C), show_size(C), menu.

exe_op(8) :- 
    write('Ingrese la categoria: '), 
    read(C), ord_lista(C), menu.

exe_op(9) :- 
    writeln('Bye!').

exe_op(_) :- 
    writeln('Opción no valida'), menu.