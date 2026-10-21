function shadeModes(ax, fe)
%SHADEMODES Shade the downconverter part of the band (x axis in GHz).
%   Each run of downconverter points is shaded from halfway to the previous
%   point to halfway to the next, so bypass and downconverter meet without
%   a gap. The shading is left out of the legend; callers say what it means
%   in the subtitle.

    f  = fe.f_MHz / 1e3;
    dc = fe.path == "downconverter";
    edges  = find(diff([false; dc(:); false]));
    starts = edges(1:2:end);
    stops  = edges(2:2:end) - 1;

    for k = 1:numel(starts)
        x1 = f(starts(k));
        x2 = f(stops(k));
        if starts(k) > 1,      x1 = (f(starts(k) - 1) + x1) / 2; end
        if stops(k) < numel(f), x2 = (x2 + f(stops(k) + 1)) / 2; end
        xregion(ax, x1, x2, FaceColor=[0.4 0.4 0.4], FaceAlpha=0.08, ...
                HandleVisibility="off");
    end
end
