Supporting information to the article 
"Statistical modeling of adaptive neural networks 
explains coexistence of avalanches and oscillations in resting human brain"
by F. Lombardi et al. https://arxiv.org/abs/2108.06686

FILES DESCRIPTION


1) adaptive_ising.cpp:

c++ source code implementation of the Montecarlo Gibbs (asynchronous heat bath) sampler to simulate the adaptive Ising model in a fully connected geometry.
It takes in input the size of the system (number of neurons, N), beta ("inverse temperature" of the Ising model), and the feedback strength (c), and it returns in output the time trace of the ongoing network activity (m) and the adaptive feedback (h). The latter are sampled with rate 1 (arbitrary units). The code can be easily modified to report in output about microscopic values as encoded in the neuronal activity variables ("spins" s[N]). This is a source code and must be compiled using a c++ compiler (e.g. c++ -o executable_name adaptive_ising.cpp) before running it.


2) beta05.dat,beta09.dat,beta1.dat,beta1.1.dat,beta2.dat:

Output examples of the code adaptive_ising.cpp.
These are simulated time traces (two columns representing m,h, sampled with rate 1) 
for different values of beta corresponding to the five different regimes outlined in the main manuscript, i.e.

beta=0.5  --> Ornstein-Uhlenbeck process
beta=0.9 --> Resonant regime
beta=1 --> Critical point
beta=1.1 --> approximately harmonic oscillations
beta=2 --> Relaxational oscillations

The feedback strength is c = 0.01 in all cases.


3) test_MEG.mat (to be downloaded from https://drive.google.com/file/d/1S2ukvDcCNEtCLPNztavp3pJQDd303azi/view?usp=sharing):

Example of a MEG data set with 273 signals (one for each sensor) sampled at 600 Hz for 4 min (144000 samples). This file contains a matrix 273 x 144000.


4) meg_analysis.m:

Matlab code to find extreme events and avalanches. It takes as input the file "test_MEG.mat" and returns as output:
(1) The distribution of avalanche sizes (plot figure(1); linear binning);
(2) A file ("test_avalanche_subject_1.dat") containing avalanche starting time (column one), ending time (column two), size in number of sensors (column three), and size in amplitude of extremes (column four);
(3) The distribution of istantaneous network excitation P(A) (plot figure(2));
(4) The distribution of quiscence durations P(I) (plot figure(3));
(5) A file ("test_extreme_events_subject_1.dat") containing the sequence of extreme events per bin (istantaneous network excitation).
Typical running time on a normal desktop computer is less than a minute.

5) tip_over_ths.m:

A function that finds the most extreme value in excursions over threshold.


6) test_avalanche_subject_1.dat:

Output file obtained from meg_analysis.m with the input file test_MEG.mat. It contains avalanche starting time (column one), ending time (column two), size in number of sensors (column three), and size in amplitude of extremes (column four).


7) test_extreme_events_subject_1.dat:

Output file obtained from meg_analysis.m with the input file test_MEG.mat. It contains the sequence of extreme events per bin (istantaneous network excitation).
