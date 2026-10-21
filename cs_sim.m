%CS_SIM Current system simulation: Friis cascade of the front end into the SDR.
%   Front end (measured NF and gain, bypass and downconverter bands) -> SDR
%   (measured NF at the payload's default gain). The SDR noise figure is
%   taken at the frequency the SDR is tuned to: the RF in bypass, the IF in
%   downconverter mode.
%
%   Settings and pipeline only; the logic is in +rx.
%   Outputs go to processed_data/cs_sim/.

clear; close all;
root = fileparts(mfilename("fullpath"));

%% Settings
rawDir     = fullfile(root, "raw_data");
feFile     = fullfile(rawDir, "Geo18_SH_Vpol_nf_gain.csv");
sdrFile    = fullfile(rawDir, "Z3U_noise_figure_vs_gain_freq.csv");
planFile   = fullfile(rawDir, "downconverter_tuning_specs.txt");
sdrGain_dB = 50;                                   % QuadSAT payload default
outDir     = fullfile(root, "processed_data", "cs_sim");

%% Load
fe   = rx.io.readFrontEnd(feFile);
sdr  = rx.io.readSdrNf(sdrFile, sdrGain_dB);
plan = rx.io.readBandPlan(planFile);

%% Cascade
feBlk = rx.physics.onGrid(fe, fe.f_MHz);
sdrRf = rx.physics.referToRf(sdr, fe, plan);
cs    = rx.physics.friisCascade({feBlk, sdrRf}, Id="cs", Name="Current system");

%% Report
rx.report.printCascadeSummary(cs, fe);

%% Plots
fig = rx.plots.nfTraces({cs, feBlk, sdrRf}, fe, FileName="cs_nf", ...
    Title=sprintf("Current system: front end → SDR (gain %g)", sdrGain_dB));

%% Save
rx.io.writeCascadeCsv(fullfile(outDir, "cs_sim.csv"), fe, cs);
rx.io.saveFigures(fig, outDir);
