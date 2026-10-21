function sdr = readSdrNf(file, gain_dB)
%READSDRNF SDR noise figure CSV + one gain setting -> block.
%   sdr = rx.io.readSdrNf(file, gain_dB) reads the column NF_dB_gain_<gain>dB
%   of the SDR noise-figure table (one column per receiver gain) into a block.
%   Frequencies are the SDR's own (tuned) frequencies; in downconverter mode
%   that is the IF, see rx.physics.referToRf.
%
%   The SDR is always the last stage, so its gain never enters the cascaded
%   noise figure: gain_dB is NaN. Empty cells (NF not measurable) are NaN.

    t = readtable(file, Delimiter=",", VariableNamingRule="preserve");

    col = sprintf("NF_dB_gain_%gdB", gain_dB);
    names = string(t.Properties.VariableNames);
    if ~ismember(col, names)
        have = names(startsWith(names, "NF_dB_gain_"));
        error("rx:io:readSdrNf:gain", "%s: no column %s. Available: %s.", ...
              file, col, strjoin(have, ", "));
    end

    sdr.name    = sprintf("SDR (gain %g)", gain_dB);
    sdr.f_MHz   = t.freq_MHz;
    sdr.nf_dB   = t.(col);
    sdr.gain_dB = nan(height(t), 1);
end
