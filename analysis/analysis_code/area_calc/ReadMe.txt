To calculate an area between 2 trajectories, they must have the same Z values, but in reality they dont.
So I fitted a function to 'a' (one of the trajectories) and interpolated it's X values according to the Z values of 'b' (the other trajectory).

The problem is you can't fit a function well if 'a' changes its direction (moves towards the screen then turn away from the screen).
I found 2 solutions to this problem:
1) If 'a' changes direction, swap it with 'b' and fit the function to 'b', do the rest normally.
	But what happens if both of them change direction?
	- In this case calcReachArea will return fail=1, and then fReachArea will sample 2 new trajectories and try again.
		This isn't good because this means the bootstrap in fReachArea isn't random.
	- calcArea doesn't deal with cases in which both trajectories flip.
	The code for this is called "swap_traj_that_flips_and_fit_the_other"
2) Draw horizontal (parallel to Z) line (h_line), calc area between each graph and that line, and subtract results.
	The code is called "between_graphs_and_h_line".