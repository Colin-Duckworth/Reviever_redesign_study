function fig = chainVsBaseline(result, baseline, fe)
%CHAINVSBASELINE One chain's NF against the current system, with the change.
%   fig = rx.plots.chainVsBaseline(result, baseline, fe) draws
%
%       top     NF vs. frequency of the chain and of the baseline
%       bottom  NF improvement, baseline NF - chain NF (positive = better)
%
%   Both are cascade results on the front end's grid. fig.Name is
%   <result.id>_nf, for rx.io.saveFigures.

    fig = figure(Name=result.id + "_nf", Color="w", Position=[100 100 950 650]);
    tl = tiledlayout(fig, 3, 1, TileSpacing="compact");
    title(tl, result.name);
    subtitle(tl, "Shaded: downconverter mode");
    xl = [fe.f_MHz(1) fe.f_MHz(end)] / 1e3;
    f  = result.f_MHz / 1e3;

    ax1 = nexttile(tl, [2 1]);
    hold(ax1, "on"); grid(ax1, "on"); box(ax1, "on");
    shadeModes(ax1, fe);
    plot(ax1, baseline.f_MHz/1e3, baseline.nf_dB, "--", Color=[0.3 0.3 0.3], ...
         LineWidth=1.2, DisplayName=baseline.name);
    plot(ax1, f, result.nf_dB, LineWidth=2, DisplayName=result.name);
    xlim(ax1, xl);
    ylabel(ax1, "Noise figure (dB)");
    legend(ax1, Location="northwest");

    ax2 = nexttile(tl);
    hold(ax2, "on"); grid(ax2, "on"); box(ax2, "on");
    shadeModes(ax2, fe);
    yline(ax2, 0, "-", Color=[0.3 0.3 0.3], HandleVisibility="off");
    plot(ax2, f, baseline.nf_dB - result.nf_dB, LineWidth=1.5);
    xlim(ax2, xl);
    xlabel(ax2, "Frequency (GHz)");
    ylabel(ax2, "Improvement (dB)");

    linkaxes([ax1 ax2], "x");
end
