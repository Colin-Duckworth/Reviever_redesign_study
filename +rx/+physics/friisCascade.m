function r = friisCascade(blocks, opts)
%FRIISCASCADE Ordered blocks -> cascaded noise figure (Friis).
%   r = rx.physics.friisCascade(blocks) cascades the blocks in the order
%   given (first = antenna side), point by point:
%
%       F = F1 + (F2 - 1)/G1 + (F3 - 1)/(G1 G2) + ...
%
%   in linear units. All blocks must be on the same grid (see onGrid). The
%   last block's gain does not affect F and may be NaN (the SDR). Any NaN
%   in a stage that matters makes that point NaN. Returns
%
%       id, name       from the options
%       f_MHz          the grid
%       nf_dB          system noise figure
%       gainToLast_dB  gain from the input to the last stage (the SDR input)
%       stageNames     block names, in order
%       contrib_pct    N x nStages: each stage's share of F - 1, in percent
%
%   r = rx.physics.friisCascade(blocks, Id="cs", Name="Current system")
%   sets the id (used in file and column names) and the display name.
%   Name defaults to the block names joined with arrows.

    arguments
        blocks (1,:) cell
        opts.Id (1,1) string = ""
        opts.Name (1,1) string = ""
    end

    f = blocks{1}.f_MHz;
    for k = 2:numel(blocks)
        if ~isequal(blocks{k}.f_MHz, f)
            error("rx:physics:friisCascade:grid", ...
                  """%s"" is not on the same frequency grid as ""%s"". Use rx.physics.onGrid first.", ...
                  blocks{k}.name, blocks{1}.name);
        end
    end

    n = numel(blocks);
    term = zeros(numel(f), n);
    gAhead = ones(numel(f), 1);          % gain of the stages before stage k
    for k = 1:n
        F = rx.util.fromDb(blocks{k}.nf_dB);
        term(:, k) = (F - 1) ./ gAhead;
        if k < n
            gAhead = gAhead .* rx.util.fromDb(blocks{k}.gain_dB);
        end
    end
    excess = sum(term, 2);

    names = strings(1, n);
    for k = 1:n
        names(k) = blocks{k}.name;
    end
    r.id           = opts.Id;
    r.name          = opts.Name;
    if r.name == "", r.name = strjoin(names, " → "); end
    r.f_MHz         = f;
    r.nf_dB         = rx.util.toDb(1 + excess);
    r.gainToLast_dB = rx.util.toDb(gAhead);
    r.stageNames    = names;
    r.contrib_pct   = 100 * term ./ excess;
end
