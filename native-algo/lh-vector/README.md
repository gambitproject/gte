lh-vector
=========

The Lemke Howson algorithm simulated with the use of covering vectors.

Running the program
===================
The program should be started with at least one argument to describe
what type of output is required, otherwise, no output is achieved.

The arguments passed into the program are as follows:
if:vVI:maep

- -a : Outputs the inverse of the tableau when restarting from an equilibrium.
- -e : Outputs an equilibrium once it has been computed.
- -f file : Outputs the LCP corresponding to the game into a file.
- -i : Allows the user to interactively select the leaving variable.
- -I n : Allows the user to interactively select the first n leaving variables.
- -m : Used to select the initialization method (see report/mideval.pdf section 2.2)
- -p : Output the LH bipartite graph
- -v : (Verbose output) output the initial and final tableaus for every equilibrium
       computation, as well as, the entering and leaving variables for every pivoting step
- -V : (Verbose output) output the tableau, entering and leaving variables after ever
       pivoting step in an equilibrium computation.

The input for the game is taken from the command line in the format shown in 'sample-input'

The file 'sample-output' shows the result of the program being run with the following setting

./inlh -e -p -v < sample-input > sample-output

Changes:
============
- Temporary fix for bug regarding restarting from an equilibrium of a degenerate game.
  Ignore the cases which generate this error, and let their LH-paths lead to equilibrium -1,
  which does not exist.