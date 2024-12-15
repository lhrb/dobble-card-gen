:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(dicts)).
:- use_module(library(http/json)).

% finite projective plane
% assuming q = p

values(P, Elements) :-
    P1 is P - 1,
    findall(X, between(0, P1, X), Elements).

triples(P, Triples) :-
    values(P, Elements),
    findall([X, Y, Z],
            (   member(X, Elements),
                member(Y, Elements),
                member(Z, Elements),
                not([X,Y,Z] = [0,0,0])),
            Triples).

% modular multiplicative inverse
% Find a scalar k such that kx mod  p = 1
%
% I learned that instead of brute force we could use gcd,
% or for our use case fermats little theorem.
mod_invers(P, X, K) :-
    Upper is P - 1,
    between(1, Upper, K),
    (X * K) mod P =:= 1,
    !.

normalize(P, [X,Y,Z], Normalized) :-
    (   X =\= 0 -> mod_invers(P, X, K);
        Y =\= 0 -> mod_invers(P, Y, K);
        Z =\= 0 -> mod_invers(P, Z, K)),
    XN is (K * X) mod P,
    YN is (K * Y) mod P,
    ZN is (K * Z) mod P,
    Normalized = [XN,YN,ZN].

% should generate q^2 + q + 1 points (assuming q = p)
enum_points(P, Points) :-
    triples(P, Triples),
    maplist(normalize(P), Triples, NormalizedPoints),
    list_to_set(NormalizedPoints, Points).

line(P, [X1,Y1,Z1], [X2,Y2,Z2], NormalizedLine) :-
    A is (Y1 * Z2 - Y2 * Z1) mod P,
    B is (Z1 * X2 - Z2 * X1) mod P,
    C is (X1 * Y2 - X2 * Y1) mod P,
    not([A,B,C] = [0,0,0]),
    normalize(P, [A,B,C], NormalizedLine).

enum_lines(P, Points, Lines) :-
    findall(Line,
            (   member(Point1, Points),
                member(Point2, Points),
                Point1 \= Point2,
                line(P, Point1, Point2, Line)),
            AllLines),
    list_to_set(AllLines, Lines).

point_on_line(P, [A,B,C], [X,Y,Z]) :-
    ((A * X) + (B * Y) + (C * Z)) mod P =:= 0.

points_on_line(_, _, [], []).
points_on_line(P, Points, [H|Lines], [[H, PointsOnLine]| Result]) :-
    include(point_on_line(P, H), Points, PointsOnLine),
    points_on_line(P, Points, Lines, Result).

projective_plane(P, Plane) :-
    enum_points(P, Points),
    enum_lines(P, Points, Lines),
    points_on_line(P, Points, Lines, Plane).

% generate output
generate_label(_,_,[],[]) :- !.
generate_label(Prefix, N, [Value|T], [[Value, Label]|Result]) :-
    atom_concat(Prefix, N, Label),
    N1 is N + 1,
    generate_label(Prefix, N1, T, Result).

find_label(Labels, Value, Label) :-
    member([Value, Label], Labels).

replace_points_with_labels(Labels, Values, Result) :-
    maplist(find_label(Labels), Values, Result).

replace_line_with_labels(LineLabels, PointLabels, [Line, Points], [Label, PointsLabel]) :-
    find_label(LineLabels, Line, Label),
    replace_points_with_labels(PointLabels, Points, PointsLabel).

replace_with_labels(Plane, LineLabels, PointLabels, Result) :-
    maplist(replace_line_with_labels(LineLabels, PointLabels), Plane, Result).

projective_plane_with_label(P, PlaneLabeled) :-
    enum_points(P, Points),
    enum_lines(P, Points, Lines),
    points_on_line(P, Points, Lines, Plane),
    generate_label('P', 0, Points, PointLabels),
    generate_label('L', 0, Lines, LineLabels),
    replace_with_labels(Plane, LineLabels, PointLabels, PlaneLabeled).

print_points([]).
print_points([H|T]) :-
    write(H), write(' '),
    print_points(T).

print_plane([]).
print_plane([[Line, Points]|Rest]) :-
    write(Line), write(': '),
    print_points(Points), nl,
    print_plane(Rest).

line_to_pair([Key, Value], Key-Value).
point_to_pair(Point, Point-"").

write_json_to_file(Points, Plane, FilePath) :-
    maplist(point_to_pair, Points, PointPairs),
    dict_create(PointDict, _, PointPairs),

    maplist(line_to_pair, Plane, LinePairs),
    dict_create(LineDict, _, LinePairs),

    JSON_DATA = json{
                     symbols: PointDict,
                     cards: LineDict
                     },

    open(FilePath, write, Stream),
    json_write(Stream, JSON_DATA, [width(128)]),
    close(Stream).

generate_point_list(Prefix, N, List) :-
    findall(Atom,
            (   between(0, N, Num),
                atom_concat(Prefix, Num, Atom)),
            List).

output_plane(P, FilePath) :-
    N is P * P + P + 1,
    generate_point_list('P', N, Points),
    projective_plane_with_label(P, Plane),
    write_json_to_file(Points, Plane, FilePath).

% run with
% ?- run_tests.
:- begin_tests(tests).

test(should_generate_possible_values_for_points) :-
    values(2, [0, 1]).

test(should_generate_seven_triples) :-
    triples(2, T), length(T, 7).

test(should_calculate_mod_invers) :-
    mod_invers(7, 2, K),
    K is 4,
    mod_invers(7, 1, K2),
    K2 is 1,
    mod_invers(7, 4, K3),
    K3 is 2.

test(should_normalize) :-
    normalize(7, [2, 3, 4], NormalizedPoint),
    NormalizedPoint = [1, 5, 2].

test(should_generate_all_points) :-
    enum_points(7, Points),
    length(Points, L),
    L = 57.

test(should_generate_all_lines) :-
    P is 7,
    enum_points(P, Points),
    writeln(Points),
    enum_lines(P, Points, Lines),
    length(Lines, L),
    L = 57.

test(should_find_the_correct_label) :-
    find_label([[[1,2,3], 'P1']], [1,2,3], X),
    X = 'P1'.

test(should_replace_points_with_labels) :-
    replace_points_with_labels([[[1,2,3], 'A']], [[1,2,3]], Result),
    Result = ['A'].

test(should_replace_line_with_labels) :-
    LineLabel = [[[0,0,1], 'L0']],
    PointLabel = [ [[1,2,3], 'P0']],
    replace_line_with_labels(LineLabel, PointLabel, [[0,0,1], [[1,2,3]]], Result),
    Result = ['L0', ['P0']].

test(should_replace_with_labels) :-
    Plane = [ [[0,0,1], [[1,2,3], [1,2,3]]] ],
    LineLabel = [[[0,0,1], 'L0']],
    PointLabel = [ [[1,2,3], 'P0']],
    replace_with_labels(Plane, LineLabel, PointLabel, Result),
    Result = [['L0', ['P0', 'P0']]].

test(should_replace_with_labels) :-
    Plane = [ [[0,1,0],[[0,0,1],[1,0,0],[1,0,1]]],
              [[0,0,1],[[0,1,0],[1,0,0],[1,1,0]]] ],
    LineLabel = [[[0,1,0],'L0'],
                 [[0,0,1],'L1'],
                 [[0,1,1],'L2'],
                 [[0,0,1],'L3'],
                 [[0,1,0],'L4'],
                 [[0,0,1],'L5'],
                 [[0,1,1],'L6']],
    PointLabel = [[[0,0,1],'P0'],
                  [[0,1,0],'P1'],
                  [[0,1,1],'P2'],
                  [[1,0,0],'P3'],
                  [[1,0,1],'P4'],
                  [[1,1,0],'P5'],
                  [[1,1,1],'P6']],
    replace_with_labels(Plane, LineLabel, PointLabel, Result),
    Result = [ ['L0', ['P0', 'P3', 'P4']],
               ['L1', ['P1', 'P3', 'P5']]].

:- end_tests(tests).
