function fig = passband(sp, pb, name)
%PASSBAND Preselector S21 with the passband and its average loss marked.
%   fig = rx.plots.passband(sp, pb, name) plots |S21| (dB) vs. frequency,
%   shades the passband found by rx.physics.passbandIl and draws the
%   average insertion loss used for the cascade. name labels the plot.
%   fig.Name is "preselector_passband", for rx.io.saveFigures.

    fig = figure(Name="preselector_passband", Color="w", Position=[100 100 950 500]);
    ax = axes(fig);
    hold(ax, "on"); grid(ax, "on"); box(ax, "on");

    xregion(ax, pb.fLow_MHz/1e3, pb.fHigh_MHz/1e3, FaceColor=[0.2 0.5 0.9], ...
            FaceAlpha=0.10, HandleVisibility="off");
    plot(ax, sp.f_MHz/1e3, 20*log10(abs(sp.S21)), LineWidth=1.5, DisplayName="S21");
    yline(ax, -pb.ilAvg_dB, "--", sprintf("Average IL %.2f dB", pb.ilAvg_dB), ...
          LineWidth=1.2, LabelHorizontalAlignment="left", HandleVisibility="off");
    plot(ax, pb.fIlMin_MHz/1e3, -pb.ilMin_dB, "o", LineWidth=1.5, ...
         DisplayName=sprintf("Minimum IL %.2f dB", pb.ilMin_dB));

    xlim(ax, [sp.f_MHz(1) sp.f_MHz(end)] / 1e3);
    xlabel(ax, "Frequency (GHz)");
    ylabel(ax, "|S21| (dB)");
    title(ax, name);
    subtitle(ax, sprintf("Shaded: passband (within %g dB of minimum loss), %.3f-%.3f GHz", ...
             pb.drop_dB, pb.fLow_MHz/1e3, pb.fHigh_MHz/1e3));
    legend(ax, Location="southeast");
end
