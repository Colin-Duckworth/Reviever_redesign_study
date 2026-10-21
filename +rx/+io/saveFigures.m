function saveFigures(figs, outDir, formats)
%SAVEFIGURES Figures -> image files (processed_data).
%   rx.io.saveFigures(figs, outDir) saves each figure as <fig.Name>.png in
%   outDir, creating the folder if needed. The plot functions set fig.Name.
%
%   rx.io.saveFigures(figs, outDir, formats) picks the formats: any of
%   "png", "pdf", "fig".

    arguments
        figs (1,:) matlab.ui.Figure
        outDir (1,1) string
        formats (1,:) string {mustBeMember(formats, ["png" "pdf" "fig"])} = "png"
    end

    if ~isfolder(outDir)
        mkdir(outDir);
    end
    for fig = figs
        for fmt = formats
            file = fullfile(outDir, fig.Name + "." + fmt);
            if fmt == "fig"
                savefig(fig, file);
            else
                exportgraphics(fig, file, Resolution=150);
            end
            fprintf("Wrote %s\n", file);
        end
    end
end
