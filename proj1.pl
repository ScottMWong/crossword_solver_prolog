:- ensure_loaded(library(clpfd)).

% puzzle_solution(+Puzzle,+Words)
% Cuts so that EXACTLY ONE solution will be found if solutions exist.
% get_puzzle_words gets all the "holes" to be filled in the puzzle
% constrain recursively selects the word with the least number of holes that it
% can unify with and unifies it with a hole.
% I originally tried to optimise with predicates such as removing fully bound
% holes at the start, and many alternate selection methods, however these 
% additions turned out to overall slow down the solve.

puzzle_solution(Puzzle,Words) :- 
    get_puzzle_words(Puzzle,Holes)
    , len_freq_sort(Words,SortWords)
    , constrain(Holes,SortWords), !.

% get_puzzle_words(+Puzzle, -Holes) 
% Get all word spaces "holes" from Puzzle
% Transpose to get columns as rows since get_row_words needs row formatting

get_puzzle_words(Puzzle, Holes) :- 
    get_rows_words(Puzzle, RHoles)
    , transpose(Puzzle, TransPuzzle)
    , get_rows_words(TransPuzzle, CHoles)
    , append(RHoles, CHoles, Holes), !.  

% get_rows_words(+Rows,-Holes)
% Get holes from list of rows provided, recursively calls get_words on each row

get_rows_words([],[]).
get_rows_words([HRow|Rows],Holes) :- 
    get_rows_words(Rows,RecHoles)
    , get_words(HRow, RowHoles)
    , append(RecHoles,RowHoles,Holes).

% get_words(+Line,-Holes)
% Given a line, get the holes(s) appropriate.
% Words is output list of words
% Don't save any one length "holes" into the list, these aren't useful anyway
% Seperator of holes are '#' 

get_words(Line, Holes) :- get_words_logic(Line,[],[],Holes).

get_words_logic([],Holes,[],Y) :- Y=Holes,!.
get_words_logic([],Holes,[_|[]],Y) :- Y=Holes,!.
get_words_logic([],Holes,N,Y) :- 
    append(Holes,[N],NHoles)
    , get_words_logic([],NHoles,[],Y).

get_words_logic([HL|Line],Holes,N,Y) :- 
    HL \== '#' -> append(N,[HL],NNew)
    , get_words_logic(Line,Holes,NNew,Y)
    ; get_words_space([HL|Line],Holes,N,Y).

get_words_space(['#'|Line],Holes,[],Y) :- get_words_logic(Line,Holes,[],Y).
get_words_space(['#'|Line],Holes,[_|[]],Y) :- get_words_logic(Line,Holes,[],Y).
get_words_space(['#'|Line],Holes,N,Y) :- 
    append(Holes,[N],NHoles)
    , get_words_logic(Line,NHoles,[],Y).

% constrain(+Holes,+Words) 
% Recursively bind the word which has the least possible matching holes to 
% a hole. Will immediately fail in next iteration if word is unbindable 
% (since 0 is least possible matches), so we don't follow unfinishable
% pathways for too long.

constrain([],[]).
constrain(Holes,[HWord|TWords]) :- 
    select(HWord,Holes,SHoles)
    , sort_by_possible_unify(TWords,SHoles,SortTWords)
    , constrain(SHoles,SortTWords).

% sort_by_possible_unify(+Words,+Holes,-SortedWords)
% sorts the list of words by how many holes in can possible unify with,
% with least possible unifying words heading the list.
% This is accomplished by adding a key to each word with this property, 
% using keysort, and removing all the keys.
sort_by_possible_unify(Words,Holes,SortedWords) :-
    unify_key(Words,Holes,AKeyW)
    , keysort(AKeyW,ASortW)
    , rem_unify_key(ASortW,SortedWords).

% Give key to word based on how many "holes" it can unify with
unify_key([],_,[]).
unify_key([HIn|TIn],Holes,[Result-p(HIn)|TOut]) :- 
    !, unify_key_evaluate(HIn,0,Holes,Result)
    , unify_key(TIn,Holes,TOut).

% To be possible unify target hole needs to be same length as word AND
% each letter needs to be same as in word or free variable.
unify_key_evaluate(_,UCount,[],Result) :- Result = UCount.
unify_key_evaluate(Word,UCount,[HHoles|THoles],Result):-
    same_length(Word,HHoles) 
    -> unify_evaluate_logic(Word,Word,UCount,[HHoles|THoles],Result)
    ; unify_key_evaluate(Word,UCount,THoles,Result).

% If Word and hole could fully unify, increase UCount by 1.
% Else continue to next hole.
unify_evaluate_logic(W,[],UCount,[[]|THoles],Result) :- 
    NUCount is UCount + 1
    , unify_key_evaluate(W,NUCount,THoles,Result).
unify_evaluate_logic(W,[HWord|TWord],UCount,[[HCheck|TCheck]|THoles],Result) :-
    (var(HCheck) ; HWord == HCheck) 
    -> unify_evaluate_logic(W,TWord,UCount,[TCheck|THoles],Result)
    ; unify_key_evaluate(W,UCount,THoles,Result).

% Recursively remove keys from words
rem_unify_key([],[]).
rem_unify_key([_-p(Word)|TIn],[Word|TOut]) :- rem_unify_key(TIn,TOut).

% len_freq_sort(+Words,-SortWords)
% Sort the given list of lists by the frequency of the lengths, 
% with less frequent being earlier

len_freq_sort(Words,SortWords) :- 
    length_key(Words,AKeyH)
    , keysort(AKeyH,ASortH)
    , list_pack(ASortH,APackH)
    , length_key(APackH,BKeyH)
    , keysort(BKeyH,BSortH)
    , rem_length_key(BSortH,CSortH)
    , flatten(CSortH,CFlatH)
    , rem_length_key(CFlatH,SortWords).

% Predicates to add or remove keys of hole length. Needed to use keysort.
length_key([],[]).
length_key([HIn|TIn],[Len-p(HIn)|OutT]) :- 
    !, length(HIn,Len)
    , length_key(TIn,OutT).

rem_length_key([],[]).
rem_length_key([_-p(Hole)|TIn],[Hole|TOut]) :- rem_length_key(TIn,TOut).

% list_pack packs the given hole tuple list into lists of lists
%  where each list of lists contains all tuples with a given hole length.
list_pack([],[]).
list_pack([L-HIn|TIn],[[L-HIn|SameL]|TOut]) :- 
    length_pack(L-HIn,TIn,RemIn,SameL)
    , list_pack(RemIn,TOut).

% length_pack creates the list of all hole tuples with same length as 
% given input hole tuple and a remainder list
length_pack(_,[],[],[]).
length_pack(L-_,[DiffL-Y|RemList],[DiffL-Y|RemList],[]) :- L \= DiffL.
length_pack(L-_,[L-H|TList],RemList,[L-H|PackList]) :- 
    length_pack(L-H,TList,RemList,PackList).
