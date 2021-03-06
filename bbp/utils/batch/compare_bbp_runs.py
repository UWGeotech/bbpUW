#!/usr/bin/env python
"""
Tool to compare bias plots from Broadband simulations done with the
bbp parallel scripts on a cluster
$Id: compare_bbp_runs.py 1024 2012-11-07 19:34:50Z fsilva $
"""

# Import Python modules
import os
import sys
import glob
import operator

def compute_avg_bias(bfn):
    """
    Compute the average bias for the bias_file
    """
    bias = 0.0
    points = 0

    bias_file = open(bfn)
    for line in bias_file:
        values = line.split()
        # Each line should have 2 items
        if len(values) != 2:
            continue
        val = float(values[1])
        # Skip added zeroes
        if val == 0.0:
            continue
        bias = bias + abs(val)
        points = points + 1

    # Done adding, calculate the average
    if points > 0:
        bias = bias / points
    # Close file
    bias_file.close()

    # Return bias
    return bias

def compare_runs(top_dir, output_file=None):
    """
    For all sub-directories in top_dir, look for the output bias
    results, calculate stats, and rank it. The result goes to
    output_file, or to stdout if output_file is not provided.
    """
    # Start with an empty list
    results = {}
    
    for item in os.listdir(top_dir):
        sim_dir = os.path.join(top_dir, item)

        # Only look at directories
        if not os.path.isdir(sim_dir):
            continue

        files = glob.glob(os.path.join(sim_dir, "*rotd50.bias"))
        if len(files) != 1:
            # bias file not found
            continue

        # Calculate stats for this simulation and add to results
        results[item] = compute_avg_bias(files[0])

    # All done, print the results
    print "Simulation    Average Bias"
    for key, val in sorted(results.iteritems(),
                           key=operator.itemgetter(1)):
        print "%10s    %8f" % (key, val)


#----------------------------------------------------------------------------
# Main
#----------------------------------------------------------------------------

if len(sys.argv) != 2:
    print "Usage: %s top_simulation_dir" % (os.path.basename(sys.argv[0]))
    sys.exit(1)

compare_runs(sys.argv[1])
