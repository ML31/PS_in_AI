%%%%%%%%%%%%%%%%%%%%%%%%%
% Median String Problem %
%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialization
% define the used alphabet
enum Alphabet;

% Alphabet = {A,C,G,T};    % include this in the data file

% create alphabet with empty character
enum AlphabetFull = I(Alphabet) ++ { Null };

% define the maximum length of any given string (also in data file)
% int: nc = 4;
int: nc;
% int: ns = 3;    % number of strings
int: ns;
 
set of int: len = 1..nc;    %set of max length

% create solution array, which has the encoded characters
array[len] of var AlphabetFull: solution;

var int: global_edit_distance;

% create array of neighbouring strings, in the implementation used we need to fill up the strings with "Null" characters up to the max length (preprocessing? or rewrite function, but its tricky)
% first manually with 3 entries of fixed size
%array[1..ns, len] of Alphabet: inread;    
array[1..ns, len] of AlphabetFull: neighbours;
% inread = [| A,T,T,A | G,A,C,T | C,G,A,A |];
% neighbours = [| I(G),I(T),I(C),Null | I(A),I(T),I(C),Null | I(T),I(G),I(G),I(T) |];    %better solution needed

% call with minizinc Minimum_editing_distance.mzn test.dzn

output [
  "num_strings=\(ns), alphabet=\(Alphabet). str_length=\(nc)\n",
];

% FUNCTIONS
% minimum editing distance function (Wagner-Fischer Implementation)
function var int: minEditDist( array[len] of var AlphabetFull: start, array[len] of AlphabetFull: goal ) =
let {   
        
        var 0..nc+1: m; var 0..nc+1: n;         % initialize m and n
        constraint forall(i in len)((start[i] = Null -> m < i) /\ (start[i] != Null -> m >= i));  % force m to the right size
        constraint forall(i in len)((goal[i] = Null -> n < i) /\ (goal[i] != Null -> n >= i));    %force n to the right size
        
        
        % better solution use fixed size, the solution string is bound to have all "Null"s at the end
        int: m_fix = length(start);
        int: n_fix = length(goal);
        
        
        array[0..m_fix, 0..n_fix] of var int: d;                      % create the distance matrix d
        constraint forall(i in 1..m) ( d[i,0] = i );          % initialize the matrix
        constraint forall(j in 1..n) ( d[0,j] = j );
        constraint d[0,0] = 0;
        
        % compute the matrix
        constraint forall(j in 1..n) (
                     forall(i in 1..m) ( 
                       d[i,j] = min([d[i-1, j] + 1, d[i, j-1] + 1, d[i-1, j-1] + (if (start[i] = goal[j]) then 0 else 2 endif)]) 
                     )     
                   );   
  } in d[m,n];




% CONSTRAINTS

% constraint, which says empty characters must be at the end
constraint forall(i in 1..nc-1) ( (solution[i] = Null) -> solution[i+1] = Null);

constraint global_edit_distance = sum([minEditDist(solution, neighbours[i,len]) | i in 1..ns]);      % sum the distances up

% SOLVE
solve minimize global_edit_distance;




output [ "An optimal median string is: "] ++ [if fix( solution[i] = Null ) then "" else show(I^-1(solution[i])) endif | i in len] ++ [" with a global editing distance of ",show(global_edit_distance)];














