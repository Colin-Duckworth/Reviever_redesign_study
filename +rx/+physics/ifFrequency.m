function f_MHz = ifFrequency(fe, plan)
%IFFREQUENCY Frequency the SDR is tuned to, at each front-end RF point.
%   f_MHz = rx.physics.ifFrequency(fe, plan) returns, for each point of the
%   front end fe:
%
%       bypass         the RF frequency itself
%       downconverter  the IF, |RF - LO|, with the LO of that point's band
%
%   The band comes from fe.band (e.g. "6250-9000 MHz"), matched to the row
%   of the band plan with the same RF start and stop. That settles the
%   points on a shared band edge (6250 MHz is in two bands). The LO is
%   taken as correct: if the IFs it gives fall outside the band plan's IF
%   numbers for the band, that is a warning, not an error.

    f_MHz = fe.f_MHz;
    dc = fe.path == "downconverter";

    for band = unique(fe.band(dc)).'
        edges = str2double(regexp(band, "\d+(\.\d+)?", "match"));
        row = find(plan.rfStart_MHz == edges(1) & plan.rfStop_MHz == edges(2));
        if numel(row) ~= 1
            error("rx:physics:ifFrequency:band", ...
                  "Band ""%s"" matches %d rows of the band plan (expected 1).", band, numel(row));
        end

        in = dc & fe.band == band;
        f_MHz(in) = abs(fe.f_MHz(in) - plan.lo_MHz(row));

        ifLim = sort([plan.ifStart_MHz(row) plan.ifStop_MHz(row)]);
        if any(f_MHz(in) < ifLim(1) | f_MHz(in) > ifLim(2))
            warning("rx:physics:ifFrequency:range", ...
                    "Band ""%s"": IF from the LO (%g MHz) is %g-%g MHz, not the band plan's %g-%g MHz. Using the LO.", ...
                    band, plan.lo_MHz(row), min(f_MHz(in)), max(f_MHz(in)), ifLim(1), ifLim(2));
        end
    end
end
