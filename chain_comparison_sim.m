%CHAIN_COMPARISON_SIM Preselector / LNA chains ahead of the current system.
%   Four chains, each cascaded (Friis) into the current system (front end
%   -> SDR) and compared with it, one figure per chain:
%
%       ps_cs       preselector -> current system
%       lna_cs      LNA -> current system
%       ps_lna_cs   preselector -> LNA -> current system
%       lna_ps_cs   LNA -> preselector -> current system (reference only:
%                   the LNA is unprotected, see the README)
%
%   Model assumptions (see the README):
%     - Preselector: the average insertion loss across the passband of the
%       measured filter state, extended over the whole band (NF = IL,
%       gain = -IL).
%     - LNA: datasheet typical values. ZX60-63GLN+ below lnaSplit_MHz,
%       ZX60-06183LN+ from it. No LNA data below 1.8 GHz, so the LNA chains
%       have no result there.
%     - SDR: the noise figure at the payload's default gain.
%
%   Settings and pipeline only; the logic is in +rx.
%   Outputs go to processed_data/chain_comparison_sim/.

clear; close all;
root = fileparts(mfilename("fullpath"));

%% Settings
rawDir       = fullfile(root, "raw_data");
feFile       = fullfile(rawDir, "Geo18_SH_Vpol_nf_gain.csv");
sdrFile      = fullfile(rawDir, "Z3U_noise_figure_vs_gain_freq.csv");
planFile     = fullfile(rawDir, "downconverter_tuning_specs.txt");
psFile       = fullfile(rawDir, "MYPCB_000.s2p");
lnaLowFile   = fullfile(rawDir, "ZX60-63GLN+_datasheet.csv");
lnaHighFile  = fullfile(rawDir, "ZX60-06183LN+_datasheet.csv");
sdrGain_dB   = 50;                                 % QuadSAT payload default
passDrop_dB  = 3;                                  % passband: within this of minimum IL
lnaSplit_MHz = 6000;                               % low-band LNA below, high-band LNA from here
outDir       = fullfile(root, "processed_data", "chain_comparison_sim");

%% Load
fe     = rx.io.readFrontEnd(feFile);
sdr    = rx.io.readSdrNf(sdrFile, sdrGain_dB);
plan   = rx.io.readBandPlan(planFile);
sp     = rx.io.readS2p(psFile);
lnaLow = rx.io.readLna(lnaLowFile);
lnaHi  = rx.io.readLna(lnaHighFile);

%% Blocks, all on the front end's grid
f     = fe.f_MHz;
feBlk = rx.physics.onGrid(fe, f);
sdrRf = rx.physics.referToRf(sdr, fe, plan);

pb = rx.physics.passbandIl(sp, passDrop_dB);
ps = rx.physics.flatBlock("Preselector", pb.ilAvg_dB, f);

lna = rx.physics.spliceBlocks(rx.physics.onGrid(lnaLow, f), rx.physics.onGrid(lnaHi, f), ...
                              lnaSplit_MHz, "LNA");

%% Cascades
cs = rx.physics.friisCascade({feBlk, sdrRf}, Id="cs", Name="Current system");

chains = {
    "ps_cs",     "Preselector → current system",       {ps, feBlk, sdrRf}
    "lna_cs",    "LNA → current system",               {lna, feBlk, sdrRf}
    "ps_lna_cs", "Preselector → LNA → current system", {ps, lna, feBlk, sdrRf}
    "lna_ps_cs", "LNA → preselector → current system", {lna, ps, feBlk, sdrRf}
};
for k = size(chains, 1):-1:1
    results(k) = rx.physics.friisCascade(chains{k, 3}, Id=chains{k, 1}, Name=chains{k, 2});
end

%% Report
rx.report.printPassband(pb, psFile);
rx.report.printCascadeSummary(cs, fe);
rx.report.printCascadeSummary(results, fe, Baseline=cs);

%% Plots
figs = rx.plots.passband(sp, pb, "Preselector PCB, filter state 000");
for k = 1:numel(results)
    figs(end+1) = rx.plots.chainVsBaseline(results(k), cs, fe); %#ok<SAGROW>
end

%% Save
rx.io.writeCascadeCsv(fullfile(outDir, "chain_comparison_sim.csv"), fe, [cs results]);
rx.io.saveFigures(figs, outDir);
