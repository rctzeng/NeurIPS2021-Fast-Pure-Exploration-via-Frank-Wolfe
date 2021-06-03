######################################################################################################
# Merge from                                                                                         #
# * Wouter Koolen: https://bitbucket.org/wmkoolen/tidnabbil/src/master/purex_games_paper/, and       #
# * Xuedong Shang: https://github.com/xuedong/LinBAI.jl                                              #
# All codes remain the same, except for functions `dump_stats` and `everyboy`.                       #                                        #
######################################################################################################
using Statistics;
using JLD2;
using Printf;
using StatsPlots;
using LaTeXStrings;
include("../standard/runit.jl"); # for types
include("thresholds.jl");
include("experiment_helpers.jl");

@load "../results/lipschitz/BAI.dat" dist μ pep srs data δs βs repeats seed
dump_stats(pep, μ, δs, βs, srs, data, repeats);
