function printCascadeSummary(results, fe, opts)
%PRINTCASCADESUMMARY Per-band NF table for each cascade result.
%   rx.report.printCascadeSummary(results, fe) prints, for each result and
%   each front-end band: min / median / max system NF and the stage that
%   contributes most to the noise (median share of F - 1). Points where the
%   NF is NaN (a block has no data there) are left out and counted.
%
%   rx.report.printCascadeSummary(..., Baseline=cs) adds the median NF
%   improvement over the baseline (baseline NF - result NF).

    arguments
        results struct
        fe struct
        opts.Baseline struct = struct([])
    end

    hasBase = ~isempty(opts.Baseline);
    bands = unique(fe.band, "stable");

    for r = results(:).'
        fprintf("\n%s\n", r.name);
        fprintf("  %-17s %-13s %6s %6s %6s", "Band", "Path", "Min", "Median", "Max");
        if hasBase, fprintf(" %8s", "Improv."); end
        fprintf("  %s\n", "Largest noise contributor");

        for band = bands.'
            in = fe.band == band;
            nf = r.nf_dB(in);
            ok = ~isnan(nf);
            path = fe.path(find(in, 1));
            fprintf("  %-17s %-13s", band, path);
            if ~any(ok)
                fprintf(" %6s %6s %6s", "-", "-", "-");
                if hasBase, fprintf(" %8s", "-"); end
                fprintf("  no data\n");
                continue
            end

            fprintf(" %6.1f %6.1f %6.1f", min(nf(ok)), median(nf(ok)), max(nf(ok)));
            if hasBase
                d = opts.Baseline.nf_dB(in) - nf;
                fprintf(" %8.1f", median(d(ok), "omitnan"));
            end
            share = median(r.contrib_pct(in & ~isnan(r.nf_dB), :), 1, "omitnan");
            [top, k] = max(share);
            fprintf("  %s (%.0f%%)", r.stageNames(k), top);
            if ~all(ok)
                fprintf("  [%d of %d points without data]", sum(~ok), numel(ok));
            end
            fprintf("\n");
        end
    end
end
