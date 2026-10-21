function fig = nfTraces(traces, fe, opts)
%NFTRACES Several NF traces vs. frequency on one axes.
%   fig = rx.plots.nfTraces(traces, fe) overlays the noise figure of each
%   trace (a block or a cascade result: anything with name, f_MHz, nf_dB).
%   The first trace is drawn thicker: pass the system result first and its
%   parts after it. The downconverter part of the band is shaded.
%
%   Options: Title (plot title), FileName (fig.Name, used by
%   rx.io.saveFigures).

    arguments
        traces (1,:) cell
        fe struct
        opts.Title (1,1) string = "Noise figure"
        opts.FileName (1,1) string = "nf"
    end

    fig = figure(Name=opts.FileName, Color="w", Position=[100 100 950 500]);
    ax = axes(fig);
    hold(ax, "on"); grid(ax, "on"); box(ax, "on");
    shadeModes(ax, fe);

    for k = 1:numel(traces)
        t = traces{k};
        width = 1.2 + 0.8*(k == 1);
        plot(ax, t.f_MHz/1e3, t.nf_dB, LineWidth=width, DisplayName=t.name);
    end

    xlim(ax, [fe.f_MHz(1) fe.f_MHz(end)] / 1e3);
    xlabel(ax, "Frequency (GHz)");
    ylabel(ax, "Noise figure (dB)");
    title(ax, opts.Title);
    subtitle(ax, "Shaded: downconverter mode");
    legend(ax, Location="northwest");
end
