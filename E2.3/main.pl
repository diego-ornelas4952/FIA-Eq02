:- use_module(library(lists)). % Para usar funciones de listas

:- initialization(load_bc). % Carga la base de conocimiento al iniciar

% Predicados para la base de conocimiento
% Carga de la base del conocimiento
load_bc :- 
    exists_file('bc.pl'),
    consult('bc.pl'),
load_bc :-
    writeln('Error al cargar la base de conocimiento. Crear al guardar').

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
    recomendacion(Categoria, Lista),
    (member (Elemento, Lista) 
    -> format('Elemento encontrado: ~q\n', [Elemento, Categoria])
    ; format('Elemento no encontrado, ¿Deseas agregarlo? (s/n)\n', [Elemento, Categoria]),
    read(Resp),
    (Resp == s -> agregar_elem(Categoria, Elemento) ; writeln('Operación cancelada'))).

% Listar elementos de una categoría
listar_elem([]).
listar_elem([H|T]) :- 
    format('- ~w~n', [H]),
    listar_elem(T).

% Comprobar lista
comprobar_lista(Categoria) :- 
    recomendacion(Categoria, Lista),
    format('~nRecomendaciones para ~w:~n', [Categoria]),
    listar_elem(Lista).

% Concatenar dos categorías
demo_concat(cat1, cat2) :-
    recomendacion(cat1, Lista1),
    recomendacion(cat2, Lista2),
    concat_propia(L1, L2, LP),
    append(L1, L2, LAp),
    format('Concatenación propia: ~q~n', [LP]),
    format('Concatenación append: ~q~n', [LAp]).

% Agregar elemento
add_elem(Categoria, Elemento) :-
    (recomendacion(Categoria, Lista)
    -> retract(recomendacion(Categoria, Lista)),
    append(Lista, [Elemento], NuevaLista);
    newList = [Elemento]),
    
    assertz(recomendacion(Categoria, NuevaLista)), % 
    guardar_bc,
    writeln('Elemento agregado con exito').

% Eliminar elemento
del_elem(Categoria, Elemento) :-
    (recomendacion(Categoria, Lista)
    -> select(Elemento, Lista, NuevaLista),
    retract(recomendacion(Categoria, Lista)),
    assertz(recomendacion(Categoria, NuevaLista)),
    guardar_bc,
    writeln('Elemento eliminado con exito')
    ; writeln('Elemento no encontrado')).

% Obtener tamaño de una categoría
size_list([], 0).
size_list([_|T], N) :- 
    size_list(T, N1), 
    N is N1 + 1.

% Mostrar tamaño de una categoría
show_size(Categoria) :-
    recomendacion(Categoria, Lista),
    size_list(Lista, N),
    format('~nRecomendaciones para ~w: ~q~n', [Categoria, N]).

% Ordenar lista
ord_lista(Categoria) :-
    recomendacion(Categoria, Lista),
    sort(Lista, listaSort),
    msort(Lista, listaMsort),
    format('~nRecomendaciones ordenadas (Sort) para ~w: ~q~n', [listaSort]),
    format('~nRecomendaciones ordenadas (Msort) para ~w: ~q~n', [listaMsort]),

% Menu
menu :-
    writeln('\n--- Menu ---\n'),
    writeln('1. Buscar elemento'),
    writeln('2. Listar elementos de categoría'),
    writeln('3. Concatenar dos categorías'),
    writeln('4. Agregar elemento'),
    writeln('5. Eliminar elemento'),
    writeln('6. Obtener tamaño de una categoría'),
    writeln('7. Ordenar lista'),
    writeln('8. Salir'),
    write('Seleccione una opción: '), 
    read(Op),
    exe_op(Op).

exe_op(1) :- 
    write('Ingrese la categoría: '), 
    read(C), write('Ingrese el elemento: '), read(E),
    buscar_elem(C, E), menu.

exe_op(2) :- 
    write('Ingrese la categoría: '), 
    read(C), 
    comprobar_lista(C), menu.

exe_op(3) :- 
    write('Ingrese la categoría 1: '), 
    read(C1), write('Ingrese la categoría 2: '), read(C2),
    demo_concat(C1, C2), menu.

exe_op(4) :- 
    write('Ingrese la categoría: '), 
    read(C), write('Ingrese el elemento que quiere añadir: '), read(E),
    add_elem(C, E), menu.

exe_op(5) :- 
    write('Ingrese la categoría: '), 
    read(C), write('Ingrese el elemento que quiere eliminar: '), read(E),
    del_elem(C, E), menu.

exe_op(6) :- 
    write('Ingrese la categoría: '), 
    read(C), show_size(C), menu.

exe_op(7) :- 
    write('Ingrese la categoría: '), 
    read(C), ord_lista(C), menu.

exe_op(8) :- 
    writeln('Bye!').

exe_op(_) :- 
    writeln('Opción no valida'), menu.