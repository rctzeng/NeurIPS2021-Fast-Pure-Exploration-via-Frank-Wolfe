######################################################################################################
# Copy from https://github.com/xuedong/LinBAI.jl  by Xuedong Shang                                   #
# Please note that XY-Adaptive can only run for one fixed δ, not multiple δs!                        #
######################################################################################################
using JLD2;
using Distributed;
using Printf;
using IterTools;
using Distributions
@everywhere include("runit_bai.jl");
@everywhere include("../utilities/thresholds.jl");
include("../utilities/experiment_helpers.jl");

# Setup: replicate the benchmark setting (ii) in (Jedra and Proutiere, 2020)
#        which uses the example considered by (Soare et al., 2014) but with ω = 0.1
dist = Gaussian();
dim = 6;
# best arm
μ = zeros(dim); µ[1] = 2.0;
arms = Vector{Float64}[];
for k = 1:dim
    v = zeros(dim); v[k] = 1.0; push!(arms, v);
end
# the last arm which is hard to distinguish with the 1st arm
ω = 0.1; v = zeros(dim); v[1] = cos(ω); v[2] = sin(ω); push!(arms, v)

pep = LinearBestArm(dist, arms);
# methods to be compared
srs = [
    BestChallengerTracking(), LazyTrackAndStop("P"), LazyTrackAndStop("H"), LazyTrackAndStop("O"),
    ConvexGame(CTracking), LearnerK(CTracking), RoundRobin()
];
#srs = [XYAdaptive()]; # separately run for different δs

"""
Note that XY-Adaptive can only run for one δ.
If you'd like to run multiple δs, e.g., δs=(0.1, 0.01, 0.0001, 0.00001),
then please remove XYAdaptive() from the srs
"""
δs = (0.1,0.01,0.001,0.0001); # Please see the above comment
βs = GK16.(δs);
repeats = 1000;
seed = 1234;

println("ω=$ω, dim=$dim, repeat $repeats times");
# compute
@time data = pmap(
    ((sr, i),) -> runit(seed + i, sr, μ, pep, βs, δs),
    Iterators.product(srs, 1:repeats),
);
dump_stats(pep, μ, δs, βs, srs, data, repeats);
# save
@save isempty(ARGS) ? "BAI.dat" : ARGS[1] dist μ pep srs data δs βs repeats seed
# visualise by loading viz.jl
