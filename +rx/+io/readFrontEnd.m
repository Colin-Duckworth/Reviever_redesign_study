function fe = readFrontEnd(file)
%READFRONTEND Front-end NF/gain CSV -> block.
%   fe = rx.io.readFrontEnd(file) reads the stitched front-end trace
%   (columns freq_MHz, nf_dB, gain_dB, path, band) into a block:
%
%       name     "Front end"
%       f_MHz    frequency, column, strictly increasing
%       nf_dB    noise figure
%       gain_dB  gain (conversion gain in downconverter bands)
%       path     "bypass" or "downconverter", per point
%       band     band label per point, e.g. "6250-9000 MHz"
%
%   path and band are extra to the common block fields; rx.physics.onGrid
%   drops them, and the plots and reports use them for mode shading and
%   per-band tables.

    t = readtable(file, Delimiter=",", TextType="string", ...
                  VariableNamingRule="preserve");

    need = ["freq_MHz" "nf_dB" "gain_dB" "path" "band"];
    missing = setdiff(need, string(t.Properties.VariableNames));
    if ~isempty(missing)
        error("rx:io:readFrontEnd:columns", "%s: missing column(s) %s.", ...
              file, strjoin(missing, ", "));
    end

    fe.name    = "Front end";
    fe.f_MHz   = t.freq_MHz;
    fe.nf_dB   = t.nf_dB;
    fe.gain_dB = t.gain_dB;
    fe.path    = t.path;
    fe.band    = t.band;

    if any(diff(fe.f_MHz) <= 0)
        error("rx:io:readFrontEnd:order", ...
              "%s: frequencies must be strictly increasing (no repeated points).", file);
    end
    bad = ~ismember(fe.path, ["bypass" "downconverter"]);
    if any(bad)
        error("rx:io:readFrontEnd:path", ...
              "%s: unknown path ""%s"" at %g MHz (expected bypass or downconverter).", ...
              file, fe.path(find(bad, 1)), fe.f_MHz(find(bad, 1)));
    end
end
