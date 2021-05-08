%%%%%%%%%%%%%%%%%%%%%%%%%
% Median String Problem %
% authors:              %
% Markus Böck           %
% Samuel Keller         %
%%%%%%%%%%%%%%%%%%%%%%%%%

% The following Constraint Programming (CP) Algorithm implements the Median String Problem.
% It is partitioned into three sections, the Initialization, the definition of the function calculating the minimum editing distance using CP
% and the solve command together with two integrity preserving constraints.


%%%%%%%%%%%%%%%%%%
% Initialization %
%%%%%%%%%%%%%%%%%%

% The model is usable with different parameter settings, which are defined in a seperate data file and are compiled together with the model
% In the comments below every instance which should be included in the data file will be marked with *
include "quick.dzn";
% Declare the finite alphabet used for a specific problem instance *
enum Alphabet;

% Declare an appended alphabet with a "Null" value to model empty spaces
enum AlphabetFull = I(Alphabet) ++ { Null };

% Declare a parameter containing the number of strings used in a problem instance *
int: ns;

% Declare a parameter containing the maximum number of characters in the longest string *
int: nc;
 
% Initialize a parameter set with the length of the search domain
set of int: len = 1..nc; 

% Declare a parameter containing the maximum number of characters of the solution string *
int: sl;

set of int: sol_len = 1..sl;

% Declare an array of decision variables, which can take any character of the expanded alphabet and will contain the solution
array[1..sl] of var AlphabetFull: solution;

% Declare an integer variable which will hold the global editing distance
var int: global_edit_distance;

% Declare a two dimensional array containing all the strings in the instance, shorter strings must be expanded with "Null" characters until matching the maximum string length *
array[1..ns, len] of AlphabetFull: neighbours;

% Output some statistics of the specific problem: the number of strings, used alphabet and maximum string length
output [ "num_strings=\(ns), alphabet=\(Alphabet). str_length=\(nc), sol_length=\(sl)\n", ];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Minimum Editing Distance (Wagner-Fischer Implementation) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define a function minEditDist which recieves two arrays of characters and calculates the minimum editing distance, by using the dynamic Wagner-Fischer algorithm
function var int: minEditDist( array[sol_len] of var AlphabetFull: start, array[len] of AlphabetFull: goal ) =

% Introduce new local variables used for the calculation
let {   
        
        % Declare variables m and n, the sizes of strings start and goal, when omitting all "Null" characters at the end
        var 0..sl+1: m; var 0..nc+1: n;
        
        % Calculate the size of m and n, by constraining them to fulfill the statement above
        constraint forall(i in sol_len)((start[i] = Null -> m < i) /\ (start[i] != Null -> m >= i));
        constraint forall(i in len)((goal[i] = Null -> n < i) /\ (goal[i] != Null -> n >= i));
        
        % Initialize parameters, whith the full length of start and goal string
        int: m_fix = length(start);
        int: n_fix = length(goal);
        
        % Declare the variable distance matrix d, which will hold the distances of substrings to each other
        array[0..m_fix, 0..n_fix] of var int: d;
        
        % Initializing the matrix d following the Wagner-Fischer algorithm, by forcing equality constraints to hold true
        constraint forall(i in 1..m) ( d[i,0] = i );
        constraint forall(j in 1..n) ( d[0,j] = j );
        constraint d[0,0] = 0;
        
        % This constraint iterativly calculates the entries of d on the submatrix d[0..m, 0..n], it is equivalent to two nested for loops
        constraint forall(j in 1..n) (
                     forall(i in 1..m) ( 
                       d[i,j] = min([d[i-1, j] + 1, d[i, j-1] + 1, d[i-1, j-1] + (if (start[i] = goal[j]) then 0 else 2 endif)]) 
                     )     
                   );
                   
  % The entry of d[m,n] is returned, which is the calculated minimum editing distance   
  } in d[m,n];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Solving with constraints %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Integrity constraint, which guarantees, that "Null" values in the solution string are only present at the end of the string
constraint forall(i in 1..sl-1) ( (solution[i] = Null) -> (solution[i+1] = Null) );

% This constraint sums up the minimum editing distances from the solution to every string and stores the value in the variable global_editing_distance
constraint global_edit_distance = sum([minEditDist(solution, neighbours[i,len]) | i in 1..ns]);

% Tell the CP Solver to solve the problem of minimzing the global editing distance
%solve minimize global_edit_distance;

% With search strategy
ann: random = int_search(solution, dom_w_deg, indomain_random, complete);

solve::random minimize global_edit_distance;

% Output the resulting median string without the "Null" values and the resulting global editing distance
output [ "Results: {median_string: "] ++ [if fix( solution[i] = Null ) then "" else show(I^-1(solution[i])) endif | i in sol_len] ++ [" global_editing_distance: ",show(global_edit_distance)] ++ ["}"];
