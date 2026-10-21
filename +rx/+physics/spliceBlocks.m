function out = spliceBlocks(low, high, fSplit_MHz, name)
%SPLICEBLOCKS Two blocks on one grid -> one block, split at a frequency.
%   out = rx.physics.spliceBlocks(low, high, fSplit_MHz, name) takes low
%   below fSplit_MHz and high at and above it. Both must be on the same grid
%   (see onGrid). Used to make one LNA from a low-band and a high-band part.

    if ~isequal(low.f_MHz, high.f_MHz)
        error("rx:physics:spliceBlocks:grid", ...
              """%s"" and ""%s"" are not on the same frequency grid.", low.name, high.name);
    end

    useHigh = low.f_MHz >= fSplit_MHz;
    out.name    = name;
    out.f_MHz   = low.f_MHz;
    out.nf_dB   = low.nf_dB;
    out.gain_dB = low.gain_dB;
    out.nf_dB(useHigh)   = high.nf_dB(useHigh);
    out.gain_dB(useHigh) = high.gain_dB(useHigh);
end
