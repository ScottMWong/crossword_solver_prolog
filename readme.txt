Assignment for Declarative Programming (COMP30020), University of Melbourne, Semester 2 2021
Created September 2021
Relevant documentation below:

* To test the crossword solving predicate, load proj1 and call puzzle_solution(+puzzle,+word_list) OR load both proj1 and test, then call test(num)
* test(19) and test(27) are student stress tests included for completeness, however will not run in a reasonable amount time 

You will write Prolog code to solve fillin puzzles. Your program should supply a predicate puzzle_solution(Puzzle, WordList) that holds when Puzzle is the representation of a solved fillin puzzle for the given list of words, WordList.

A fillin puzzle will be represented as a list of lists, each of the same length and each representing a single row of the puzzle. Each element in each of these lists is either a: '#', denoting a solid, unfillable square; an underscore (_), representing a fillable square; or a single, lower case letter (e.g., h), denoting a pre-filled square.

For example, suppose you have a 3 by 3 puzzle with the four corners filled in solid and one pre-filled letter. This would be represented by the Puzzle argument:

    ?- Puzzle = [['#',h,'#'],[_,_,_],['#',_,'#']]

A word list will be represented as a list of lists. Each list is a list of characters, spelling a word. For the above puzzle, the accompanying word list may be:

    ?- WordList = [[h,a,t], [b,a,g]]

You can assume that when your puzzle_solution/2 predicate is called, both arguments will be a proper list of proper lists, and its second argument will be ground. You may assume your code will only be tested with proper puzzles, which have at most one solution. Of course, if the puzzle is not solvable, the predicate should fail, and it should never succeed with a puzzle argument that is not a valid solution. For example, your program would solve the above puzzle as below:

    ?- Puzzle = [['#',h,'#'],[_,_,_],['#',_,'#']], WordList = [[h,a,t], [b,a,g]], puzzle_solution(Puzzle, WordList).
    Puzzle = [[#, h, #], [b, a, g], [#, t, #]],
    WordList = [[h, a, t], [b, a, g]] ;
    false.

The marking tests were timed, however without knowing

